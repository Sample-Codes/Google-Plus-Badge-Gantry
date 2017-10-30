REM #######################################################
REM #                                                     #
REM #   Google+ Badge - Particle for Gantry 5             #
REM #                                                     #
REM #   Purpose: This project adds the Google             #
REM #            Plus Profile, Page or Community          #
REM #            Badge to the Gantry templating           #
REM #            framework.                               #
REM #                                                     #
REM #   Author: Marian Tanase <marian@tanase.it>          #
REM #           Andreas Kar (thex) <andreas.kar@gmx.at>   #
REM #                                                     #
REM #######################################################

@echo off

REM --- Script Variables ---
set remove_folders=0
set log_files=0

REM --- Packaging Variables ---
set langs_upper=EN, IT, DE
set default_lang=EN

set prj_id=gpb
set prj_rev=v1.1.0
set prj_name=gplus-badge
set prj_fullname=Google Plus Badge - Particle

set pkg_part_only=particle.only
set pkg_leg=legacy
set pkg_helium=helium
set pkg_hydro=hydrogen
set pkg_j3=j3

REM --- File Variables ---
set part_def_files=LICENSE, README.md
set plugin_def_files=LICENSE.pdf
set file_ext=yaml, html.twig
set lang_ext=yaml

REM --- Folder Variables ---
set folder_root=..\..
set folder_src_def=src\default
set folder_src_leg=src\legacy
set folder_platform_joomla=platform\joomla
set folder_trans=translation
set folder_part=particles
set folder_temp=temp
set folder_release=release
set folder_def=default
set folder_leg=legacy
set folder_helium=%pkg_j3%_%pkg_helium%
set folder_hydro=%pkg_j3%_%pkg_hydro%

REM --- Message Variables ---
set msg_start=Start packaging process for creating release.
set msg_finished=Successful finished packaging process.
set msg_success=successfully created.

REM --- Start Script ---
echo.
echo -------------------------------
echo  %prj_fullname% #
echo -------------------------------
echo.
echo %msg_start%

IF NOT EXIST %folder_temp% ( mkdir %folder_temp% )
IF NOT EXIST %folder_release% (	mkdir %folder_release% )

echo.
cd %folder_temp%

REM --- Call Particle Default / Legacy Package Creation ----
call :create_particle "%folder_def%" "" "%folder_src_def%"
call :create_particle "%folder_leg%" "%pkg_leg%." "%folder_src_leg%"

REM --- Call Hydrogen / Helium Package Creation ----
call :create_j3plugin "%folder_hydro%" "%pkg_hydro%"
call :create_j3plugin "%folder_helium%" "%pkg_helium%"

REM --- Stop Script and Cleanup ---
cd..
IF %remove_folders% == 1 (
	rmdir "%folder_temp%" /S /Q
	REM rmdir "%folder_release%" /S /Q
)
IF "%log_files%" == "0" ( echo. )
echo %msg_finished%
echo.
goto:EOF

REM --- Create Particle Only Package(s) for different languages ---
REM --- Parameters: %~1 = destination folder particle, %~2 = archive name, %~3 = yaml base path
:create_particle
	setlocal EnableDelayedExpansion
	(for %%l in (%langs_upper%) do (

		set "lang=%%l"
		set folder_out=%~1_!lang!
		set package_name=%prj_id%.%pkg_part_only%.%~2!lang!.%prj_rev%
		
		IF NOT EXIST !folder_out! ( mkdir !folder_out! )
		
		(for %%f in (%part_def_files%) do ( call :copy_general_files "%folder_root%\%%f" "!folder_out!"	))
		(for %%e in (%file_ext%) do ( call :copy_particle_files "%%e" "!lang!" "%~3" "!folder_out!" ))
		call :create_archives "!package_name!" "!folder_out!" "1" "1"

		IF %remove_folders% == 1 ( rmdir "!folder_out!" /S /Q )
		IF "%log_files%" == "1" ( echo ------------------------- )
		echo !package_name! %msg_success%
		IF "%log_files%" == "1" ( echo. )
	))
	endlocal
goto :EOF

REM --- Create Joomla 3 Plugin Packages for different languages ---
REM --- Parameters: %~1 = destination folder plugin, %~2 = template name
:create_j3plugin
	setlocal EnableDelayedExpansion
	(for %%l in (%langs_upper%) do (

		set "lang=%%l"
		set folder_out=%~1_!lang!
		set folder_out_sub=!folder_out!\%folder_part%
		set folder_platform=%folder_root%\%folder_platform_joomla%
		set package_name=%prj_id%.%pkg_j3%.%~2.!lang!.%prj_rev%

		IF NOT EXIST !folder_out! ( mkdir !folder_out! )
		IF NOT EXIST !folder_out_sub! ( mkdir !folder_out_sub! )
		
		(for %%e in (%file_ext%) do ( call :copy_particle_files "%%e" "!lang!" "%folder_src_def%" "!folder_out_sub!" ))	
		(for %%f in (%plugin_def_files%) do ( call :copy_general_files "!folder_platform!\%%f" "!folder_out!" ))
		call :copy_plugin_files "!lang!" "!folder_platform!" "%~2" "!folder_out!"
		call :create_archives "!package_name!" "!folder_out!" "1" "0"

		IF %remove_folders% == 1 (
			rmdir "!folder_out_sub!" /S /Q
			rmdir "!folder_out!" /S /Q
		)
		IF "%log_files%" == "1" ( echo ------------------------- )
		echo !package_name! %msg_success%
		IF "%log_files%" == "1" ( echo. )
	))
	endlocal
goto :EOF

REM --- Copies the particle files to the current temp folder ---
REM --- Parameters: %~1 = extension, %~2 = language, %~3 = yaml base path, %~4 = output folder
:copy_particle_files 
	set prj_trans_path=%folder_root%\%~3\%folder_trans%\!lang!\%prj_name%.%~1
	
	IF "%~1" == "%lang_ext%" (
		set prj_path=%folder_root%\%~3\%prj_name%.%~1
		IF "%~2" == "%default_lang%" (
			IF "%log_files%" == "1" ( echo !prj_path! )
			copy !prj_path! %~4 >Nul
		) ELSE (
			IF "%log_files%" == "1" ( echo !prj_trans_path! )
			copy !prj_trans_path! %~4 >Nul
		)
	) ELSE (
		set prj_path=%folder_root%\%folder_src_def%\%prj_name%.%~1
		IF "%log_files%" == "1" ( echo !prj_path! )
		copy !prj_path! %~4 >Nul
	)
goto :EOF

REM --- Copies the general project files like license and readme  ---
REM --- Parameters: %~1 = source folder, %~2 = output folder
:copy_general_files
	IF "%log_files%" == "1" ( echo %~1 )
	copy %~1 %~2 >Nul
goto :EOF

REM --- Copies the Joomla 3 Plugin files ---
REM --- Parameters: %~1 = language, %~2 = platform folder, %~3 = template name, %~4 = output folder
:copy_plugin_files
	set temp_path=%~2\%~3\%prj_name%
	set temp_trans_path=%~2\%~3\%folder_trans%\%~1\%prj_name%
	
	IF "%~1" == "%default_lang%" (
		IF "%log_files%" == "1" ( echo !temp_path!.xml )
		copy !temp_path!.xml %~4 >Nul
	) ELSE (
		IF "%log_files%" == "1" ( echo !temp_trans_path!.xml )
		copy !temp_trans_path!.xml %~4 >Nul
	)
goto :EOF

REM --- Creates Release Archives ---
REM --- Parameters: %~1 = package name, %~2 = output folder, %~3 = create zip, %~4 = create tar.gz
:create_archives
	set arch_dest=..\%folder_release%\%~1
	
	IF "%~3" == "1" (
		set zip_dest=!arch_dest!.zip
		IF EXIST !zip_dest! ( del !zip_dest! )
		7z a -tzip !zip_dest! .\%~2\* >Nul
	)
	IF "%~4" == "1" (
		set tar_dest=!arch_dest!.tar
		set gzip_dest=!arch_dest!.tar.gz
		7z a -ttar !tar_dest! .\%~2\* >Nul
		IF EXIST !gzip_dest! ( del !gzip_dest! )
		7z a !gzip_dest! !tar_dest! >Nul
		del !tar_dest!
	)
goto :EOF