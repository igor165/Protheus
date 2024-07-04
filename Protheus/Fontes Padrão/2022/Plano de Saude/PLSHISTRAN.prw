#INCLUDE "PROTHEUS.CH"   

Function PLSHISTINT()
Local cAlias 			:= "BIZ"   
Local aCores 			:= {}  
Private cCadastro := OemToAnsi("Histórico de Transações")
Private aRotina 	:= {}                       	

AADD(aRotina,{"Pesquisar" 					  ,"AxPesqui"  ,0,1})
AADD(aRotina,{"Visualizar"					  ,"AxVisual"  ,0,2})
AADD(aRotina,{"Salvar Log"					  ,"DlgGrvLog" ,0,6})
AADD(aRotina,{"Legenda"							  ,"Legenda"   ,0,7})

AADD(aCores,{"AllTrim(BIZ_TPARQ) == 'E'  .And. AllTrim(BIZ_CARINI) == 'N'" ,"BR_VERDE"	 })
AADD(aCores,{"AllTrim(BIZ_TPARQ) == 'R'  .And. AllTrim(BIZ_CARINI) == 'N'" ,"BR_AZUL"		 })
AADD(aCores,{"AllTrim(BIZ_TPARQ) == 'LA' .And. AllTrim(BIZ_CARINI) == 'N'","BR_AMARELO" })
AADD(aCores,{"AllTrim(BIZ_TPARQ) == 'ER' .And. AllTrim(BIZ_CARINI) == 'N'","BR_CINZA"	 })   
AADD(aCores,{"AllTrim(BIZ_TPARQ) == 'P'  .And. AllTrim(BIZ_CARINI) == 'N'" ,"BR_BRANCO"	 })
AADD(aCores,{"AllTrim(BIZ_TPARQ) == 'PN' .And. AllTrim(BIZ_CARINI) == 'N'","BR_PRETO"	 })
AADD(aCores,{"AllTrim(BIZ_CARINI) == 'S'","BR_VERMELHO"})	  

dbSelectArea(cAlias)
DbGoTop() 	
mBrowse(,,,, cAlias,,,,,,aCores)

Return      

Function DlgGrvLog()
Local cCaminho 
Local cRootPath := GetSRVProfString("ROOTPATH","")
//Pegando o caminho desejado para salvamento do Log
cCaminho := cGetFile( ,"Selecione o local para salvar o arquivo log",, cRootPath, .F., ;
nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
  
nHandle := FCreate(cCaminho + Trim(BIZ->BIZ_NOARQ) + ".log",0)   
If (nHandle != -1 .And. cCaminho != "")		       		
	FWrite(nHandle,OemToAnsi(Trim(BIZ->BIZ_TXLOG)))	
	FClose(nHandle)
	MsgInfo("Arquivo log salvo com sucesso!")
EndIf	
Return Nil

Function Legenda() 
 
Local aLegenda := {} 
 
AADD(aLegenda,{"BR_VERDE" 	 ,"Especialidade" 							 }) 
AADD(aLegenda,{"BR_AZUL" 		 ,"RDA"													 }) 
AADD(aLegenda,{"BR_AMARELO"  ,"Local de Atendimento"  			 }) 
AADD(aLegenda,{"BR_CINZA" 	 ,"Especialidade do Local"			 }) 
AADD(aLegenda,{"BR_BRANCO" 	 ,"Procedimentos"								 })
AADD(aLegenda,{"BR_PRETO"    ,"Procedimentos não Autorizados"})    	
AADD(aLegenda,{"BR_VERMELHO" ,"Carga Inicial" 							 })    	

 
BrwLegenda(cCadastro, "Tipos de Arquivo", aLegenda) 
 
Return Nil         
