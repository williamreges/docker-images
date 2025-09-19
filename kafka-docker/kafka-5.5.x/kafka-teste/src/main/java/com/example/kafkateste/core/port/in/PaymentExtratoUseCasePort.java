package com.example.kafkateste.core.port.in;

import com.example.kafkateste.core.domain.PaymentDTO;

public interface PaymentExtratoUseCasePort {
    void paymentExtrato(PaymentDTO paymentDTO);
}
