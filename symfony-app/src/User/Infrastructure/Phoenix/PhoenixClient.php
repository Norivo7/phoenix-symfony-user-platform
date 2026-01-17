<?php

declare(strict_types=1);

use Symfony\Contracts\HttpClient\HttpClientInterface;

final readonly class PhoenixClient
{
    public function __construct(
        private HttpClientInterface $httpClient,
        private string $baseUrl,
    ) {}

    public function listUsers(array $filters = []): array
    {
        $response = $this->httpClient->request('GET', $this->baseUrl . '/users', [
            'query' => $filters,
        ]);

        return $response->toArray()['data'] ?? [];
    }
}