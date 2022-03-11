package com.arcadia.DataQualityDashboard.service;

import com.arcadia.DataQualityDashboard.config.FilesManagerProperties;
import com.arcadia.DataQualityDashboard.service.request.FileSaveRequest;
import com.arcadia.DataQualityDashboard.service.response.FileSaveResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import static org.springframework.http.MediaType.MULTIPART_FORM_DATA;

@Service
@RequiredArgsConstructor
@Slf4j
public class FilesManagerServiceImpl implements FilesManagerService {
    private final FilesManagerProperties filesManagerProperties;

    private final RestTemplate restTemplate;

    @Override
    public ByteArrayResource getFile(String key) {
        return restTemplate.getForObject(
                filesManagerProperties.getUrl() + "/api/{key}",
                ByteArrayResource.class,
                key
        );
    }

    @Override
    public FileSaveResponse saveFile(FileSaveRequest model) {
        log.info("Sending Rest request to save file");
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MULTIPART_FORM_DATA);

        MultiValueMap<String, Object> map = new LinkedMultiValueMap<>();
        map.add("username", model.getUsername());
        map.add("dataKey", model.getDataKey());
        map.add("file", model.getScanReport());

        HttpEntity<MultiValueMap<String, Object>> request = new HttpEntity<>(map, headers);

        ResponseEntity<FileSaveResponse> responseEntity = restTemplate.postForEntity(
                filesManagerProperties.getUrl() + "/api",
                request,
                FileSaveResponse.class
        );

        return responseEntity.getBody();
    }

    @Override
    public void deleteFile(String key) {
        restTemplate.delete(
                filesManagerProperties.getUrl() + "/api/${key}",
                key
        );
    }
}
