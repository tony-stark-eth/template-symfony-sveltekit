<?php

declare(strict_types=1);

namespace App\Shared\Controller;

use Doctrine\DBAL\Connection;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final readonly class HealthController
{
    public function __construct(
        private Connection $connection,
    ) {
    }

    #[Route('/api/v1/health', name: 'health_check', methods: ['GET'])]
    public function health(): JsonResponse
    {
        return new JsonResponse([
            'status' => 'ok',
            'timestamp' => new \DateTimeImmutable()->format(\DateTimeInterface::ATOM),
        ]);
    }

    #[Route('/api/v1/health/ready', name: 'health_ready', methods: ['GET'])]
    public function ready(): JsonResponse
    {
        try {
            $this->connection->executeQuery('SELECT 1');
        } catch (\Throwable) {
            return new JsonResponse(
                [
                    'status' => 'error',
                    'message' => 'Database unavailable',
                ],
                Response::HTTP_SERVICE_UNAVAILABLE,
            );
        }

        return new JsonResponse([
            'status' => 'ok',
            'timestamp' => new \DateTimeImmutable()->format(\DateTimeInterface::ATOM),
        ]);
    }
}
