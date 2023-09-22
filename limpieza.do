
cd "C:\Users\DELL\Downloads\PUCP\2023-2\TALLER HERR CUANTI\ENPOVE 2022"

import delimited using "769-Modulo1719\800 Género y victimización", clear

tab p200_n
tab vresfin
tab resfin
tab p802_1
tab p802_2
tab p802_3
tab p807

rename (ccdd ccpp ccdi) (CCDD CCPP CCDI)
tostring CCDD, replace
tostring CCPP, replace
tostring CCDI, replace

replace CCDD="0"+CCDD if length(CCDD)==1
replace CCPP="0"+CCPP if length(CCPP)==1
replace CCDI="0"+CCDI if length(CCDI)==1

*Variable de Violencia Genero 1
rename (p802_1 p802_2) (index_1 index_2)
gen index_g1 = substr(index_1 , 1 , 1)
destring index_g1, replace
  label define genero_ 1 "Si" 2 "No"
  label value index_g1 genero_
br index_g1

recode index_g1 (1=1 "Si") (2=0 "No"), gen(vgen_1) 
label var vgen_1 "Violencia Género 1"

*Variable de Violencia Genero 2
gen index_g2 = substr(index_2 , 1 , 1)
destring index_g2, replace
  label define gen2 1 "Si" 2 "No"
  label value index_g2 gen2
br index_g2

recode index_g2 (1=1 "Si") (2=0 "No"), gen(vgen_2) 
label var vgen_2 "Violencia Género 2"

*Variable de Prostitucion
gen index_g3 = substr(p807 , 1 , 1)
destring index_g3, replace
  label define gen3 1 "Si" 2 "No"
  label value index_g3 gen3
br index_g3

recode index_g3 (1=1 "Si") (2=0 "No"), gen(prost) 
label var prost "Servicios Sexuales"

*Eliminar variables
keep CCDD-estrato vgen_* prost factorfinal

tab departamento vgen_1
tab departamento vgen_2
tab departamento prost

save "datos_modificados.dta", replace

*Colapsar datos por departamento
	preserve
		
		collapse (mean) vgen_1 [iw=factorfinal], by(CCDD)
		save "datos_modificados_vgen1.dta", replace
		
	restore
	
use "Data/datos_modificados_vgen1.dta", clear 
br


use "Data/datos_modificados.dta", clear
	preserve
		
		collapse (mean) vgen_2 [iw=factorfinal], by(CCDD)
		save "datos_modificados_vgen2.dta", replace
		
	restore
	
use "Data/datos_modificados_vgen2.dta", clear 
br


use "Data/datos_modificados.dta", clear
	preserve
		
		collapse (mean) prost [iw=factorfinal], by(CCDD)
		save "datos_modificados_prost.dta", replace
		
	restore
	
use "Data/datos_modificados_prost.dta", clear 
br

*Merge 3 indices departamentales
merge 1:1 CCDD using "Data/datos_modificados_vgen2.dta"
br
rename _merge _merge1
merge 1:1 CCDD using "Data/datos_modificados_prost.dta"
rename _merge _merge2

drop _merge*

save "datos_departamental.dta", replace

*---------------------------------------------------------
*Colapsar datos por distrito LIMA
clear all
use "Data/datos_modificados.dta", replace
cd "C:\Users\DELL\Downloads\PUCP\2023-2\TALLER HERR CUANTI\TAREA_MAPAS"
rename departamento DEPARTAMENTO
drop if DEPARTAMENTO!= "LIMA"
tab CCDI
br

	preserve
		
		collapse (mean) vgen_1 [iw=factorfinal], by(CCDI)
		save "datos_modificadosdi_vgen1.dta", replace
		
	restore
	
use "Data/datos_modificadosp_vgen1.dta", clear 
br


use "Data/datos_modificados.dta", clear
	preserve
		
		collapse (mean) vgen_2 [iw=factorfinal], by(CCDI)
		save "Data/datos_modificadosdi_vgen2.dta", replace
		
	restore
	
use "Data/datos_modificadosp_vgen2.dta", clear 
br


use "Data/datos_modificados.dta", clear
	preserve
		
		collapse (mean) prost [iw=factorfinal], by(CCDI)
		save "Data/datos_modificadosdi_prost.dta", replace
		
	restore
	
use "Data/datos_modificadosdi_prost.dta", clear 
br

*Merge 3 indices distritales LIMA
use "Data/datos_modificadosdi_vgen1.dta", clear
merge 1:1 CCDI using "Data/datos_modificadosdi_vgen2.dta"
br
rename _merge _merge1
merge 1:1 CCDI using "Data/datos_modificadosdi_prost.dta"
rename _merge _merge2

drop _merge*

save "Data/datosLimaDistrital.dta", replace