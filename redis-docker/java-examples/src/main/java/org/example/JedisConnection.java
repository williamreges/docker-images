package org.example;

import redis.clients.jedis.HostAndPort;
import redis.clients.jedis.Jedis;

public class JedisConnection {
    public static void main(String[] args) {
        Jedis jedis = new Jedis(new HostAndPort("localhost", 6379));
        jedis.auth("1234!");
        jedis.ttl("50000");

        String response = jedis.ping();
        System.out.println("Conexão: " + response);

        jedis.set("chave-jedis", "valor-jedis");
        String valor = jedis.get("chave-jedis");
        System.out.println("Valor: " + valor);

        jedis.close();
    }
}