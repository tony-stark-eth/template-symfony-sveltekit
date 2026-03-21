<?php

declare(strict_types=1);

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void {
    $container->extension('lexik_jwt_authentication', [
        'secret_key' => '%env(JWT_SECRET_KEY)%',
        'public_key' => '%env(JWT_PUBLIC_KEY)%',
        'pass_phrase' => '%env(JWT_PASSPHRASE)%',
        'token_ttl' => '%env(int:JWT_TOKEN_TTL)%',
    ]);
};
