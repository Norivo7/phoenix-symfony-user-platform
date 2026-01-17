<?php

declare(strict_types=1);

namespace App\User\Application\Query;

use App\User\Infrastructure\Phoenix\PhoenixClient;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler]
final readonly class ListUsersHandler
{
    public function __construct(private PhoenixClient $client) {}

    public function __invoke(ListUsersQuery $q): array
    {
        $params = [];

        if ($q->firstName !== null && $q->firstName !== '') {
            $params['first_name'] = $q->firstName;
        }
        if ($q->lastName !== null && $q->lastName !== '') {
            $params['last_name'] = $q->lastName;
        }
        if ($q->gender !== null && $q->gender !== '') {
            $params['gender'] = $q->gender;
        }
        if ($q->birthdateFrom !== null && $q->birthdateFrom !== '') {
            $params['birthdate_from'] = $q->birthdateFrom;
        }
        if ($q->birthdateTo !== null && $q->birthdateTo !== '') {
            $params['birthdate_to'] = $q->birthdateTo;
        }
        if ($q->sortBy !== null && $q->sortBy !== '') {
            $params['sort_by'] = $q->sortBy;
        }
        if ($q->sortDir !== null && $q->sortDir !== '') {
            $params['sort_dir'] = $q->sortDir;
        }

        return $this->client->listUsers($params);
    }
}
