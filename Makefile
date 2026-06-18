.PHONY: install upgrade run run-ios run-android analyze test format format-check build-apk build-ios build-web clean clean-all clean-android rebuild-all deploy-edge deploy-edge-all deploy-supabase deploy-all deploy-hosting deploy-secrets verify-supabase supabase-link setup-db deploy-migrations clean-ios

SUPABASE_PROJECT_REF ?= gtvpsukmmjhszpopulfe

install:
	flutter pub get

upgrade:
	flutter pub upgrade

run:
	@if [ ! -f .env ]; then \
		echo "Missing .env — copy .env.example to .env and add your Supabase credentials."; \
		exit 1; \
	fi
	flutter run -d chrome --dart-define-from-file=.env

run-ios:
	@if [ ! -f .env ]; then \
		echo "Missing .env — copy .env.example to .env and add your Supabase credentials."; \
		exit 1; \
	fi
	flutter run -d ios --dart-define-from-file=.env

run-android:
	@if [ ! -f .env ]; then \
		echo "Missing .env — copy .env.example to .env and add your Supabase credentials."; \
		exit 1; \
	fi
	flutter run -d android --dart-define-from-file=.env

analyze:
	flutter analyze

test:
	flutter test

test-integration:
	flutter test integration_test/

format:
	dart format .

format-check:
	dart format --output=none --set-exit-if-changed .

build-apk:
	flutter build apk --release --dart-define-from-file=.env

build-ios:
	flutter build ios --release --dart-define-from-file=.env

build-web:
	flutter build web --release --dart-define-from-file=.env

clean:
	flutter clean
	rm -rf build/

clean-android:
	cd android && ./gradlew clean --no-daemon 2>/dev/null || true
	rm -rf android/.gradle android/app/build android/build

clean-ios:
	rm -rf ios/.symlinks ios/Pods ios/Podfile.lock ios/Flutter/ephemeral
	rm -rf ios/Runner.xcworkspace/xcuserdata ios/Runner.xcodeproj/xcuserdata

clean-all: clean clean-ios clean-android
	rm -rf .dart_tool/flutter_build
	@echo "✓ Full clean complete."

rebuild-all:
	@if [ ! -f .env ]; then \
		echo "Missing .env — copy .env.example to .env first."; \
		exit 1; \
	fi
	$(MAKE) install
	cd ios && pod install
	flutter analyze
	flutter test
	flutter build web --release --dart-define-from-file=.env
	flutter build apk --release --dart-define-from-file=.env
	flutter build ios --release --dart-define-from-file=.env --no-codesign
	@echo ""
	@echo "✓ Rebuild complete:"
	@echo "  Web:     build/web/"
	@echo "  Android: build/app/outputs/flutter-apk/app-release.apk"
	@echo "  iOS:     build/ios/iphoneos/Runner.app (unsigned)"

supabase-link:
	supabase link --project-ref $(SUPABASE_PROJECT_REF) --yes

deploy-edge: deploy-edge-all

deploy-edge-all:
	supabase functions deploy daily-reminder --no-verify-jwt
	supabase functions deploy wallet-pass --no-verify-jwt

setup-db:
	@if [ ! -f .env ]; then \
		echo "Missing .env file."; \
		exit 1; \
	fi
	@./scripts/setup_db.sh

deploy-migrations: setup-db

deploy-supabase: setup-db deploy-edge-all verify-supabase

deploy-secrets:
	@./scripts/set_edge_secrets.sh

deploy-hosting:
	@./scripts/deploy_hosting.sh

deploy-all: setup-db deploy-edge-all deploy-secrets verify-supabase
	@echo ""
	@echo "✓ Supabase stack deployed. Run 'make deploy-hosting' to build web artifacts."

verify-supabase:
	@./scripts/verify_supabase.mjs