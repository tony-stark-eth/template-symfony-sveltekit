<?php

declare(strict_types=1);

namespace App\Shared\Monolog;

use Monolog\Handler\AbstractProcessingHandler;
use Monolog\Level;
use Monolog\LogRecord;
use OpenTelemetry\API\Globals;
use OpenTelemetry\API\Logs\LogRecord as OtelLogRecord;
use OpenTelemetry\API\Logs\Severity;

final class OtelHandler extends AbstractProcessingHandler
{
    public function __construct(Level $level = Level::Debug, bool $bubble = true)
    {
        parent::__construct($level, $bubble);
    }

    protected function write(LogRecord $record): void
    {
        $logger = Globals::loggerProvider()->getLogger('monolog');

        $otelRecord = new OtelLogRecord($record->message)
            ->setSeverityNumber(Severity::fromPsr3($record->level->toPsrLogLevel()))
            ->setSeverityText($record->level->name)
            ->setAttributes([
                'monolog.channel' => $record->channel,
            ]);

        $logger->emit($otelRecord);
    }
}
