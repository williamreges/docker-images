package com.example.kafkateste.core.port.out;

import com.example.kafkateste.core.domain.PaymentDTO;

public interface PaymentExtratoProducerPort {
    void paymentExtratoProducer(PaymentDTO paymentDTO);
}
