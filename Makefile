.PHONY: install upgrade run run-ios run-android analyze test format format-check build-apk build-ios build-web clean deploy-edge deploy-edge-all deploy-supabase verify-supabase supabase-link setup-db deploy-migrations site-install site-dev site-build clean-ios

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

clean-ios:
	rm -rf ios/.symlinks ios/Pods ios/Podfile.lock
	flutter pub get
	cd ios && pod install

supabase-link:
	supabase link --project-ref $(SUPABASE_PROJECT_REF) --yes

deploy-edge: deploy-edge-all

deploy-edge-all:
	supabase functions deploy daily-reminder --no-verify-jwt
	supabase functions deploy wallet-pass

setup-db:
	@if [ ! -f .env ]; then \
		echo "Missing .env file."; \
		exit 1; \
	fi
	@./scripts/setup_db.sh

deploy-migrations: setup-db

deploy-supabase: setup-db deploy-edge-all verify-supabase

verify-supabase:
	@./scripts/verify_supabase.mjs

site-install:
	cd site && npm install

site-dev:
	cd site && npm run dev

site-build:
	cd site && npm run build