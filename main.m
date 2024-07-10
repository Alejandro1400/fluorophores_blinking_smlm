%% Script - Main Fluorophores Blinking SMLM
%
% author:  Alejandro Salgado
% date:    06.10.2024
% version: 1.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc, clear all

%% Folder Workspace access

% Get current folder
folder = fileparts(which(mfilename)); 

% Add folder and subfolders to path
addpath(genpath(folder));

% Call the preprocess_image function
% preprocess_image_gui(folder);

% Call the image_reconstruction function
image_reconstruction_gui(folder);