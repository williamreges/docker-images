package com.example.kafkateste.adapter.integration;

import com.example.kafkateste.core.domain.Extrato;
import com.example.kafkateste.core.domain.Payment;
import com.example.kafkateste.core.domain.PaymentDTO;
import com.example.kafkateste.core.domain.PaymentData;
import com.example.kafkateste.core.port.out.PaymentExtratoProducerPort;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Component
public class PaymentExtratoProducerImpl implements PaymentExtratoProducerPort {

    private final KafkaTemplate<String, Payment> producerRecord;

    @Override
    public void paymentExtratoProducer(PaymentDTO paymentDTO) {
        var extratos =
                List.of(
                        new Extrato("11111111111", 100.0f, true),
                        new Extrato("22222222222", 200.0f, true),
                        new Extrato("33333333333", 300.0f, true));

        var avro = Payment.newBuilder()
                .setData(PaymentData.newBuilder()
                        .setAgencia("1622")
                        .setCpf("22869991800")
                        .setConta("317475")
                        .setExtratos(extratos)
                        .build())
                .build();

        producerRecord.send("payment-extrato", avro)
                .addCallback(
                        (success) ->
                                log.info("envio de payload com sucesso"),
                        (failure) ->
                                log.info("falha de envio do payload"));

    }

}
