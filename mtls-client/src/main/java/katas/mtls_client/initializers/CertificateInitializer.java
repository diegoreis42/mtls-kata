package katas.mtls_client.initializers;

import java.io.IOException;

import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;

@Component
public class CertificateInitializer {

    @PostConstruct
    public void init() {
        try {
            ProcessBuilder pb = new ProcessBuilder("bash", "generate-certificates.sh");
            pb.inheritIO();
            Process process = pb.start();
            int exitCode = process.waitFor();
            if (exitCode != 0) {
                throw new RuntimeException("Failed to generate certificates.");
            }
        } catch (IOException | InterruptedException e) {
            throw new RuntimeException("Failed to run the certificate generation script.", e);
        }
    }
}
