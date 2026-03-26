<?php

declare(strict_types=1);

namespace App\Shared\EventListener;

use OpenTelemetry\API\Trace\Span;
use OpenTelemetry\API\Trace\StatusCode;
use Symfony\Component\EventDispatcher\Attribute\AsEventListener;
use Symfony\Component\HttpKernel\Event\ExceptionEvent;
use Symfony\Component\HttpKernel\KernelEvents;

#[AsEventListener(event: KernelEvents::EXCEPTION, priority: 200)]
final class ExceptionTraceListener
{
    public function __invoke(ExceptionEvent $event): void
    {
        $span = Span::getCurrent();

        if (! $span->isRecording()) {
            return;
        }

        $throwable = $event->getThrowable();

        $span->recordException($throwable);
        $span->setStatus(StatusCode::STATUS_ERROR, $throwable->getMessage());
    }
}
