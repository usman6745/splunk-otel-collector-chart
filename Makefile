.PHONY: render
render:
	rm -rf rendered/manifests
	# Set for one of each telemetry type.
	for i in metrics traces logs; do \
		dir=rendered/manifests/"$$i-only"; \
		mkdir -p "$$dir"; \
		helm template \
			--namespace default \
			--values rendered/values.yaml \
			--set splunkObservability.metricsEnabled=false,splunkObservability.tracesEnabled=false,splunkObservability.logsEnabled=false,splunkObservability.$${i}Enabled=true \
			--output-dir "$$dir" \
			default helm-charts/splunk-otel-collector; \
		mv "$$dir"/splunk-otel-collector/templates/* "$$dir"; \
		rm -rf "$$dir"/splunk-otel-collector; \
	done

	# Platform Logs
	dir=rendered/manifests/platform-logs-with-o11y-metrics-and-traces; \
	mkdir -p "$$dir"; \
	helm template \
		--namespace default \
		--values rendered/values.yaml \
		--output-dir "$$dir" \
		--set splunkObservability.logsEnabled=false \
    --set splunkPlatform.logsEnabled=true,splunkPlatform.token=changeme,splunkPlatform.endpoint=https://changeme.com \
		default helm-charts/splunk-otel-collector; \
	mv "$$dir"/splunk-otel-collector/templates/* "$$dir"; \
	rm -rf "$$dir"/splunk-otel-collector
#     --set clusterReceiver.config.exporters.splunk_hec/o11y.log_data_enabled=wokkawokka \

	# Default configuration deployment.
	dir=rendered/manifests/agent-only; \
	mkdir -p "$$dir"; \
	helm template \
		--namespace default \
		--values rendered/values.yaml \
		--output-dir "$$dir" \
		default helm-charts/splunk-otel-collector; \
	mv "$$dir"/splunk-otel-collector/templates/* "$$dir"; \
	rm -rf "$$dir"/splunk-otel-collector

	# Gateway mode deployment only.
	dir=rendered/manifests/gateway-only; \
	mkdir -p "$$dir"; \
	helm template \
		--namespace default \
		--values rendered/values.yaml \
		--output-dir "$$dir" \
		--set agent.enabled=false,gateway.enabled=true,clusterReceiver.enabled=false \
		default helm-charts/splunk-otel-collector; \
	mv "$$dir"/splunk-otel-collector/templates/* "$$dir"; \
	rm -rf "$$dir"/splunk-otel-collector

	# Native OTel logs collection instead of fluentd.
	dir=rendered/manifests/otel-logs; \
	mkdir -p "$$dir"; \
	helm template \
		--namespace default \
		--values rendered/values.yaml \
		--output-dir "$$dir" \
		--set logsEngine=otel,splunkObservability.logsEnabled=true \
		default helm-charts/splunk-otel-collector; \
	mv "$$dir"/splunk-otel-collector/templates/* "$$dir"; \
	rm -rf "$$dir"/splunk-otel-collector

	# eks/fargate deployment (with recommended gateway)
	dir=rendered/manifests/eks-fargate; \
	mkdir -p "$$dir"; \
	helm template \
		--namespace default \
		--values rendered/values.yaml \
		--output-dir "$$dir" \
		--set distribution=eks/fargate,gateway.enabled=true,cloudProvider=aws \
		default helm-charts/splunk-otel-collector; \
	mv "$$dir"/splunk-otel-collector/templates/* "$$dir"; \
	rm -rf "$$dir"/splunk-otel-collector
