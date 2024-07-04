/* 
	SQL PARA CONSULTAR MEU BANCO DE 
	TABELA SRA = FUNCIONARIOS
	  ''   SPI = BANCO DE HORAS
*/
Use Totvs33
Select	RA_NOME
	, RA_CIC
	, CONVERT(DATE, PI_DATA) PI_DATA
	, PI_QUANT
	, PI_QUANTV
	, PI_DTBAIX
	, PI_STATUS
	FROM SPI010
	LEFT JOIN SRA010 SRA on
			  SRA.RA_FILIAL = PI_FILIAL
		AND PI_MAT = RA_MAT
	WHERE PI_MAT = '000293' 
	AND PI_DATA BETWEEN '20220325' AND '20220422'


/*
 MINHA MATRICULA 
				Select * from SRA010 where RA_RG = '37.736.313-3'
TABELA DE FUNCIONARIOS
				SELECT TOP 5 * FROM SRA010
MEU BANCO DE HORAS SEM NOME
				SELECT TOP 5 * from SPI010 WHERE PI_MAT = '000293' AND D_E_L_E_T_ = ''
TABELA DE EVENTOS: 
				NO CASO DESTA CONSULTA O P9_COD � 106, CUJO NOME SE D� A "H.EXTRA  50% AUTOR  "

				SELECT * FROM SP9010 WHERE P9_CODIGO = 106 AND D_E_L_E_T_ = ' '

*/
/*000293 matricula*/