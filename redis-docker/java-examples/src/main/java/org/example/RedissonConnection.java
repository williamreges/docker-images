package org.example;

import org.redisson.Redisson;
import org.redisson.api.RedissonClient;
import org.redisson.config.Config;

public class RedissonConnection {
    public static void main(String[] args) {
        Config config = new Config();
        config.useSingleServer()
                .setAddress("redis://lab-redis-cluster.jhuwus.0001.sae1.cache.amazonaws.com:6379");

        RedissonClient redisson = Redisson.create(config);

        try {
            redisson.getKeys().flushall();
            redisson.getBucket("chave").set("valor");
            var valor = redisson.getBucket("chave").get();
            System.out.println("Valor recuperado: " + valor);
        } finally {
            redisson.shutdown();
        }
    }
}