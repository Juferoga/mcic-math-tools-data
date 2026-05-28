% Script maestro para generar figuras de VT, LD y clasificacion
% para los 3 datasets nuevos CORREGIDOS:
%   S&P 500: volatilidad absoluta (|log-returns|)
%   FRED DGS10: diferencias diarias (estacionarias)
%   BTC/USDT: volatilidad absoluta (|log-returns|)
% Ejecutar con: matlab -nodisplay -nosplash -r "run('generate_all_figures_v2.m'); exit"

clear; close all; clc;

% Agregar paths de funciones del profesor y src
addpath('doc/clase');
addpath('src');

outputDir = 'doc/actividades/actividad6/imgs';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% ============================================================
%  DATASET 1: S&P 500 VOLATILIDAD
%% ============================================================
fprintf('=== DATASET 1: S&P 500 (volatilidad |r_t|) ===\n');
sp500 = csvread('data/gspc_volatility.csv');
fprintf('  Muestras: %d\n', length(sp500));

% VT
fprintf('  Ejecutando VT...\n');
figure('Visible', 'off');
[H_vt_sp, Hmin_sp, Hmax_sp] = vt(sp500);
print(fullfile(outputDir, 'snp500_diagrama_vt.png'), '-dpng', '-r200');
close;
fprintf('  H(VT) = %.4f (%.4f < H < %.4f)\n', H_vt_sp, Hmin_sp, Hmax_sp);

% LD
fprintf('  Ejecutando LD...\n');
figure('Visible', 'off');
[H_ld_sp, alpha_sp] = LD(sp500);
print(fullfile(outputDir, 'snp500_diagrama_ld.png'), '-dpng', '-r200');
close;
fprintf('  H(LD) = %.4f, alpha = %.4f\n', H_ld_sp, alpha_sp);

% Clasificacion
fprintf('  Ejecutando clasificador...\n');
try
    figure('Visible', 'off');
    [H_sp, clas_sp, R2vt_sp, R2tau_sp] = clasificar_fractal(sp500, 0.85, 0.90);
    print(fullfile(outputDir, 'snp500_clasificacion_fractal.png'), '-dpng', '-r200');
    close;
    fprintf('  Clasificacion: %s, H=%.4f, R2_vt=%.4f, R2_tau=%.4f\n', clas_sp, H_sp, R2vt_sp, R2tau_sp);
catch ME
    fprintf('  [ERROR clasificador S&P 500]: %s\n', ME.message);
end

%% ============================================================
%  DATASET 2: FRED DGS10 DIFERENCIAS
%% ============================================================
fprintf('\n=== DATASET 2: FRED DGS10 (diferencias diarias) ===\n');
dgs10 = csvread('doc/data/fred_dgs10_diff.csv');
fprintf('  Muestras: %d\n', length(dgs10));

% VT
fprintf('  Ejecutando VT...\n');
figure('Visible', 'off');
[H_vt_dgs, Hmin_dgs, Hmax_dgs] = vt(dgs10);
print(fullfile(outputDir, 'dgs10_diagrama_vt.png'), '-dpng', '-r200');
close;
fprintf('  H(VT) = %.4f (%.4f < H < %.4f)\n', H_vt_dgs, Hmin_dgs, Hmax_dgs);

% LD
fprintf('  Ejecutando LD...\n');
figure('Visible', 'off');
[H_ld_dgs, alpha_dgs] = LD(dgs10);
print(fullfile(outputDir, 'dgs10_diagrama_ld.png'), '-dpng', '-r200');
close;
fprintf('  H(LD) = %.4f, alpha = %.4f\n', H_ld_dgs, alpha_dgs);

% Clasificacion
fprintf('  Ejecutando clasificador...\n');
try
    figure('Visible', 'off');
    [H_dgs, clas_dgs, R2vt_dgs, R2tau_dgs] = clasificar_fractal(dgs10, 0.85, 0.90);
    print(fullfile(outputDir, 'dgs10_clasificacion_fractal.png'), '-dpng', '-r200');
    close;
    fprintf('  Clasificacion: %s, H=%.4f, R2_vt=%.4f, R2_tau=%.4f\n', clas_dgs, H_dgs, R2vt_dgs, R2tau_dgs);
catch ME
    fprintf('  [ERROR clasificador DGS10]: %s\n', ME.message);
end

%% ============================================================
%  DATASET 3: BTC/USDT VOLATILIDAD
%% ============================================================
fprintf('\n=== DATASET 3: BTC/USDT (volatilidad |r_t|) ===\n');
btc = csvread('data/btcusdt_volatility.csv');
fprintf('  Muestras: %d\n', length(btc));

% VT
fprintf('  Ejecutando VT...\n');
figure('Visible', 'off');
[H_vt_btc, Hmin_btc, Hmax_btc] = vt(btc);
print(fullfile(outputDir, 'btc_diagrama_vt.png'), '-dpng', '-r200');
close;
fprintf('  H(VT) = %.4f (%.4f < H < %.4f)\n', H_vt_btc, Hmin_btc, Hmax_btc);

% LD
fprintf('  Ejecutando LD...\n');
figure('Visible', 'off');
[H_ld_btc, alpha_btc] = LD(btc);
print(fullfile(outputDir, 'btc_diagrama_ld.png'), '-dpng', '-r200');
close;
fprintf('  H(LD) = %.4f, alpha = %.4f\n', H_ld_btc, alpha_btc);

% Clasificacion
fprintf('  Ejecutando clasificador...\n');
try
    figure('Visible', 'off');
    [H_btc, clas_btc, R2vt_btc, R2tau_btc] = clasificar_fractal(btc, 0.85, 0.90);
    print(fullfile(outputDir, 'btc_clasificacion_fractal.png'), '-dpng', '-r200');
    close;
    fprintf('  Clasificacion: %s, H=%.4f, R2_vt=%.4f, R2_tau=%.4f\n', clas_btc, H_btc, R2vt_btc, R2tau_btc);
catch ME
    fprintf('  [ERROR clasificador BTC]: %s\n', ME.message);
end

fprintf('\n=== TODAS LAS FIGURAS GENERADAS ===\n');
fprintf('Salida en: %s\n', outputDir);
