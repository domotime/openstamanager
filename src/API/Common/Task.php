<?php

namespace API\Common;

use API\Interfaces\CreateInterface;
use API\Interfaces\RetrieveInterface;
use API\Resource;
use Carbon\Carbon;
use Models\Cache;
use Tasks\Log;

class Task extends Resource implements RetrieveInterface, CreateInterface
{
    public function retrieve($request)
    {
        $logs = Log::latest()
            ->take(1000)->get()
            ->groupBy('task.name');

        return [
            'results' => $logs->toArray(),
        ];
    }

    public function create($request)
    {
        $database = database();

        // Rimozione della registrazione del cron attuale
        $ultima_esecuzione = Cache::get('Ultima esecuzione del cron');
        $ultima_esecuzione->set(null);

        // Segnalazione della chiusura al cron attuale
        $cron_id = Cache::get('ID del cron');
        $cron_id->set(null);

        // Rimozione dell'eventuale blocco sul cron
        $disattiva = Cache::get('Disabilita cron');
        $disattiva->set(null);

        // Salvataggio delle modifiche
        $database->commitTransaction();

        // Attesa della conclusione per il cron precedente
        $in_esecuzione = Cache::get('Cron in esecuzione');
        while ($in_esecuzione->content) {
            $timestamp = (new Carbon())->addMinutes(1)->getTimestamp();
            time_sleep_until($timestamp);

            $in_esecuzione->refresh();
        }

        // Chiamata al cron per l'avvio
        $this->request();

        // Riavvio transazione
        $database->beginTransaction();
    }

    /**
     * Richiesta HTTP fire-and-forget.
     *
     * @source https://cwhite.me/blog/fire-and-forget-http-requests-in-php
     */
    protected function request()
    {
        $endpoint = BASEURL.'/cron.php';
        $postData = json_encode([]);

        $endpointParts = parse_url($endpoint);
        $endpointParts['path'] = $endpointParts['path'] ?: '/';
        $endpointParts['port'] = $endpointParts['port'] ?: $endpointParts['scheme'] === 'https' ? 443 : 80;

        $contentLength = strlen($postData);

        $request = "POST {$endpointParts['path']} HTTP/1.1\r\n";
        $request .= "Host: {$endpointParts['host']}\r\n";
        $request .= "User-Agent: OpenSTAManager API v1\r\n";
        $request .= "Authorization: Bearer api_key\r\n";
        $request .= "Content-Length: {$contentLength}\r\n";
        $request .= "Content-Type: application/json\r\n\r\n";
        $request .= $postData;

        $prefix = substr($endpoint, 0, 8) === 'https://' ? 'tls://' : '';

        $socket = fsockopen($prefix.$endpointParts['host'], $endpointParts['port']);
        fwrite($socket, $request);
        fclose($socket);
    }
}
