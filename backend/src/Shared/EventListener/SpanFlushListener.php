<?php

declare(strict_types=1);

namespace App\Shared\EventListener;

use OpenTelemetry\API\Globals;
use OpenTelemetry\SDK\Logs\LoggerProviderInterface;
use OpenTelemetry\SDK\Trace\TracerProviderInterface;
use Symfony\Component\EventDispatcher\Attribute\AsEventListener;
use Symfony\Component\HttpKernel\KernelEvents;

/**
 * FrankenPHP worker mode keeps the process alive between requests.
 * Without this listener, spans and logs batch up and only flush on process death.
 */
#[AsEventListener(event: KernelEvents::TERMINATE, priority: -1024)]
final class SpanFlushListener
{
    public function __invoke(): void
    {
        $tracerProvider = Globals::tracerProvider();
        if ($tracerProvider instanceof TracerProviderInterface) {
            $tracerProvider->forceFlush();
        }

        $loggerProvider = Globals::loggerProvider();
        if ($loggerProvider instanceof LoggerProviderInterface) {
            $loggerProvider->forceFlush();
        }
    }
}
