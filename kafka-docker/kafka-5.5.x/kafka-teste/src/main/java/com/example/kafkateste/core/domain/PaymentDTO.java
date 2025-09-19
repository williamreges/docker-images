package com.example.kafkateste.core.domain;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.Data;

import java.util.List;

@lombok.Data
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class PaymentDTO {

    private PaymentData data;

    @lombok.Data
    public static class PaymentData {
        private String cpf;
        private String agencia;
        private String conta;

        private List<Extrato> extratos;

    }

    @Data
    public static class Extrato {
        private String cpf;
        private float valor;
        private boolean status_pagamento;
    }

}
