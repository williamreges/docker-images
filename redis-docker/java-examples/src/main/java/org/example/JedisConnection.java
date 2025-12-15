package org.example;

import redis.clients.jedis.Jedis;

public class JedisConnection {
    public static void main(String[] args) {
        // Endpoint do ElasticCache
        String host = "lab-redis-cluster.jhuwus.0001.sae1.cache.amazonaws.com";
        int port = 6379;

        // Conectar ao Redis
        Jedis jedis = new Jedis(host, port);

        // Testar conexão
        String response = jedis.ping();
        System.out.println("Conexão: " + response);

        // Operações básicas
        jedis.set("chave", "valor");
        String valor = jedis.get("chave");
        System.out.println("Valor: " + valor);

        // Fechar conexão
        jedis.close();
    }
}