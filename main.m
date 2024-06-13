%% Script - Main Fluorophores Blinking SMLM

% author:  Alejandro Salgado
% date:    06.10.2024
% version: 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc, clear all

%% Folder Workspace access

% Add folder and subfolders to path
addpath(genpath(folder));

% Get current folder
folder = fileparts(which(mfilename)); 

% Call the preprocess_image function
preprocess_image(folder);

