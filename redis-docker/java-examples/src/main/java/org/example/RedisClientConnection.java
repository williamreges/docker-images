package org.example;

import io.lettuce.core.RedisClient;
import io.lettuce.core.RedisURI;
import io.lettuce.core.api.StatefulRedisConnection;
import io.lettuce.core.api.sync.RedisCommands;

public class RedisClientConnection {
    public static void main(String[] args) {

        RedisClient client = RedisClient.create(RedisURI.Builder.redis("localhost")
                .withSsl(false)
                .withPassword("1234!")
                .withDatabase(0)
                .build());
        StatefulRedisConnection<String, String> connection = client.connect();
        RedisCommands<String, String> commands = connection.sync();
        try {
            String pong = commands.ping();
            System.out.println("Conexão bem-sucedida: " + pong);

            commands.set("chave-lettuce", "valor-lettuce");
            String valor = commands.get("chave-lettuce");
            System.out.println("Valor recuperado: " + valor);
        } finally {
            client.shutdown();
        }
    }
}