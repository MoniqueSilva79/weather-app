# 🌦️ App de Clima (Flutter + OpenWeather)

Aplicativo mobile que mostra o **clima atual** e a **previsão das próximas horas** para qualquer cidade, consumindo a API do OpenWeatherMap.

## ✨ Funcionalidades
- Busca por cidade
- Temperatura, sensação térmica, umidade, vento e descrição em português
- Ícone do clima
- Previsão para as próximas 24 horas (de 3 em 3 horas)
- Tratamento de erros (cidade não encontrada, sem internet)

## 🧰 Tecnologias
- Flutter 3 / Dart
- Pacote `http`
- [OpenWeatherMap API](https://openweathermap.org/api) (plano gratuito)

## 🔑 Chave da API
Crie uma conta gratuita em https://home.openweathermap.org/users/sign_up e copie sua chave.
A chave é passada na hora de rodar, com `--dart-define`, e não fica no código.

## 🚀 Como rodar
```bash
git clone https://github.com/MoniqueSilva79/weather-app.git
cd weather-app
flutter create .
flutter pub get
flutter run --dart-define=OWM_API_KEY=sua_chave_aqui
```

## 📚 O que pratiquei
- Consumo de API REST no mobile
- `FutureBuilder` e estados de carregamento e erro
- Parse de JSON em modelos Dart

## 🗺️ Próximos passos
- [ ] Localização automática com `geolocator`
- [ ] Cidades favoritas
- [ ] Tema que muda conforme o clima
