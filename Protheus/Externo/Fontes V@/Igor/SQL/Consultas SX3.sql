
select * from SX3010 WHERE X3_ARQUIVO = 'ZDE' 
SELECT * FROM ZDE010
select * from SIX010 where INDICE = 'ZDE'

--U_IniCampo("ZDEDETAIL","ZDE_ITEM")
select top 50 * from SC5010 
--Validação em ZVI_TES
--existcpo("SF4",M->FA_TES) .and.  if(!empty(M->FA_IMPOSTO),existchav("SFA",M->FA_TES+M->FA_IMPOSTO),.T.)                         
--Validação ZVI_PRODUT
--A093Prod(.F.).and.existchav("SB1").and.IIF(Subs(M->B1_COD,1,3)=="MOD",A010MOD(),.T.) .And. A010GRADE() .And. Freeforuse("SB1")  

--Iif(INCLUI,GetSX8Num('ZDE','ZDE_CODIGO'),ZDE->ZDE_CODIGO)
--Iif(INCLUI,dDataBase,ZDE->ZDE_DATA)                                                                                             
/*
USE TotvsHomo33 
update SX3010 
	SET X3_RELACAO = 'Iif(INCLUI,GetSX8Num("ZDE","ZDE_CODIGO"),ZDE->ZDE_CODIGO)' 
	WHERE X3_ARQUIVO = 'ZDE' 
	  AND X3_CAMPO = 'ZDE_CODIGO'

USE TotvsHomo33 
update SX3010
	SET X3_RELACAO = 'Iif(INCLUI,dDataBase,ZDE->ZDE_DATA)' 
	WHERE X3_ARQUIVO = 'ZDE' 
	  AND X3_CAMPO = 'ZDE_DATA'

USE TotvsHomo33 
update SX3010
	SET X3_TIPO = 'C'
		,X3_PICTURE = ' '
	WHERE X3_ARQUIVO = 'ZDE' 
	  AND X3_CAMPO = 'ZDE_ITEM'



USE TotvsHomo33 
update SX3010
	SET X3_RELACAO = 'Iif(INCLUI,U_IniCampo("ZDEDETAIL","ZDE_ITEM"),ZDE->ZDE_ITEM)' 
	WHERE X3_ARQUIVO = 'ZDE' 
	  AND X3_CAMPO = 'ZDE_ITEM'	



USE TotvsHomo33 
update SX3010
	SET X3_TAMANHO = '3' 
	WHERE X3_ARQUIVO = 'ZDE' 
	  AND X3_CAMPO = 'ZDE_ITEM'	

	  
USE TotvsHomo33 
update SX3010
set X3_VALID = ' '
	WHERE X3_ARQUIVO = 'ZDE' 
	  AND X3_CAMPO = 'ZDE_TIPO'	
	  
	  */

	USE TotvsHomo33 
update SX3010
	SET X3_PICTURE = ' '
	WHERE X3_ARQUIVO = 'ZDE' 
	  AND X3_CAMPO = 'ZDE_TIPO'

	
USE TotvsHomo33 
update SX3010
	SET X3_RELACAO = '' 
	WHERE X3_ARQUIVO = 'ZDE' 
	  AND X3_CAMPO = 'ZDE_ITEM'	