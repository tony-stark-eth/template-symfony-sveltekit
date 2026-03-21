<?php

declare(strict_types=1);

namespace Tests\Integration\Controller;

use App\Shared\Controller\HealthController;
use PHPUnit\Framework\Attributes\CoversClass;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

#[CoversClass(HealthController::class)]
final class HealthControllerTest extends WebTestCase
{
    public function testHealthEndpointReturnsOk(): void
    {
        $client = self::createClient();
        $client->request(\Symfony\Component\HttpFoundation\Request::METHOD_GET, '/api/v1/health');

        self::assertResponseIsSuccessful();
        self::assertResponseStatusCodeSame(200);

        /** @var array{status: string, timestamp: string} $data */
        $data = json_decode((string) $client->getResponse()->getContent(), true, 512, JSON_THROW_ON_ERROR);

        self::assertSame('ok', $data['status']);
        self::assertArrayHasKey('timestamp', $data);
    }

    public function testHealthEndpointReturnsJsonContentType(): void
    {
        $client = self::createClient();
        $client->request(\Symfony\Component\HttpFoundation\Request::METHOD_GET, '/api/v1/health');

        self::assertResponseHeaderSame('content-type', 'application/json');
    }

    public function testReadyEndpointReturnsOkWhenDatabaseIsUp(): void
    {
        $client = self::createClient();
        $client->request(\Symfony\Component\HttpFoundation\Request::METHOD_GET, '/api/v1/health/ready');

        self::assertResponseIsSuccessful();
        self::assertResponseStatusCodeSame(200);

        /** @var array{status: string, timestamp: string} $data */
        $data = json_decode((string) $client->getResponse()->getContent(), true, 512, JSON_THROW_ON_ERROR);

        self::assertSame('ok', $data['status']);
        self::assertArrayHasKey('timestamp', $data);
    }

    public function testReadyEndpointReturnsJsonContentType(): void
    {
        $client = self::createClient();
        $client->request(\Symfony\Component\HttpFoundation\Request::METHOD_GET, '/api/v1/health/ready');

        self::assertResponseHeaderSame('content-type', 'application/json');
    }
}
