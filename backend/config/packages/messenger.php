<?php

declare(strict_types=1);

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void {
    $container->extension('framework', [
        'messenger' => [
            'failure_transport' => 'failed',
            'transports' => [
                'async' => [
                    'dsn' => '%env(MESSENGER_TRANSPORT_DSN)%',
                    'options' => [
                        'use_notify' => true,
                        'check_delayed_interval' => 1000,
                    ],
                    'retry_strategy' => [
                        'max_retries' => 3,
                        'multiplier' => 2,
                    ],
                ],
                'failed' => [
                    'dsn' => 'doctrine://default?queue_name=failed',
                ],
            ],
            'routing' => [
                'Symfony\Component\Mailer\Messenger\SendEmailMessage' => 'async',
            ],
        ],
    ]);

    if ($container->env() === 'test') {
        $container->extension('framework', [
            'messenger' => [
                'transports' => [
                    'async' => ['dsn' => 'in-memory://'],
                ],
            ],
        ]);
    }
};
