<?php

declare(strict_types=1);

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void {
    $container->extension('monolog', [
        'channels' => ['deprecation'],
    ]);

    if ($container->env() === 'dev') {
        $container->extension('monolog', [
            'handlers' => [
                'main' => [
                    'type' => 'stream',
                    'path' => 'php://stderr',
                    'level' => 'debug',
                    'channels' => ['!event'],
                ],
                'console' => [
                    'type' => 'console',
                    'process_psr_3_messages' => false,
                    'channels' => ['!event', '!doctrine', '!console'],
                ],
            ],
        ]);
    }

    if ($container->env() === 'test') {
        $container->extension('monolog', [
            'handlers' => [
                'main' => [
                    'type' => 'fingers_crossed',
                    'action_level' => 'error',
                    'handler' => 'nested',
                    'excluded_http_codes' => [404, 405],
                    'channels' => ['!event'],
                ],
                'nested' => [
                    'type' => 'stream',
                    'path' => 'php://stderr',
                    'level' => 'debug',
                ],
            ],
        ]);
    }

    if ($container->env() === 'prod') {
        $container->extension('monolog', [
            'handlers' => [
                'main' => [
                    'type' => 'stream',
                    'path' => 'php://stderr',
                    'level' => 'info',
                    'formatter' => 'monolog.formatter.json',
                    'channels' => ['!event'],
                ],
                'deprecation' => [
                    'type' => 'stream',
                    'channels' => ['deprecation'],
                    'path' => 'php://stderr',
                    'formatter' => 'monolog.formatter.json',
                ],
            ],
        ]);
    }
};
