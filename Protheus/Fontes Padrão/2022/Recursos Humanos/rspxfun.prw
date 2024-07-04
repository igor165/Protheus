#include "Protheus.ch"
#include "rspxfun.ch"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.                      Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё FNC  Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Car.Ё06/08/14ЁTQENRXЁIncluido o fonte da 11 para a 12 e efetua-Ё╠╠
╠╠Ё            Ё        Ё      Ёda a limpeza.                             Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё RSPLoadExec	ЁAutorЁ  Igor Franzoi     Ё Data Ё29/06/2009Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁFuncao executada a cada rotina (menu) chamado pelo RSP		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRSPLoadExec													Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ё															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RSPLoadExec()

If FindFunction("SPFLoadExec()")
	SPFLoadExec()
EndIf

Return (Nil)


/*/
зддддддддддбддддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁValidArqRsp   Ё Autor ЁGustavo M.            Ё Data Ё20/04/2012Ё
цддддддддддеддддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida o Relacionamentos dos Arquivos do SIGARSP               Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁValidArqRsp( lShowHelp )                           			   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ                                         					   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁlRet -> Se todos os Arquivos Estao com o Relacionamento CorretoЁ
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	       Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerica                                                       Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function ValidArqRsp( lShowHelp )
Return( RspRelationFile( lShowHelp ) )

/*/
зддддддддддбдддддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁPonRelationFileЁ Autor ЁGustavo M.           Ё Data Ё20/04/2012Ё
цддддддддддедддддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida o Relacionamentos dos Arquivos do SIGARSP     		   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRspRelationFile( void )                            			   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ                                         					   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁlRet -> Se todos os Arquivos Estao com o Relacionamento CorretoЁ
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	       Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerica                                                       Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RspRelationFile( )

Local lRetModo		:= .F.
Local cTabela		:= ""
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Coloca o Ponteiro do Mouse em Estado de Espera               Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Consiste o Modo de Acesso dos Arquivos                       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Begin Sequence    
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQL"),.T.,.F.))
		cTabela:="SQL" 
		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQM"),.T.,.F.)) 
		cTabela:="SQM"  
		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF  
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQI"),.T.,.F.))  
		cTabela:="SQI" 
		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQR"),.T.,.F.))  
   		cTabela:="SQR"    
   		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF
End Sequence

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Ponteiro do Mouse                                 Ё
дддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	
CursorArrow()


Return( lRetModo )