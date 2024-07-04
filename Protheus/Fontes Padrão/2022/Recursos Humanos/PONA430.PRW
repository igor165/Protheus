#INCLUDE "PONA430.CH"
#INCLUDE "PROTHEUS.CH"

Static lPort1510 	:= Port1510() 	//Verifica se Portaria 1510/2009 esta em vigor.
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё PONA430  Ё Autor Ё Leandro Drumond       Ё Data Ё 28/10/09 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Cadastro de Motivos para Desconsideracao                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PONA430()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                   Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё FNC  Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia C.  Ё20/05/14ЁTPQAN3ЁIncluido o fonte da 11 para a 12 e efetu- Ё╠╠
╠╠Ё            Ё        Ё      Ёada a limpeza.                            Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function PONA430

Local aArea			:= GetArea()

Private cCadastro  := OemToAnsi( STR0009 ) // "Cadastro de Motivos"

//--Inclui registros padroes na RFD
GeraRFD()

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё So Executa se os Modos de Acesso dos Arquivos Relacionados esЁ
Ё tiverm OK.											  	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
IF ValidArqPon()

	Private aRotina := MenuDef()
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Endereca a funcao de BROWSE                                  Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSelectArea ( "RFD" )
	dbGoTop()
	mBrowse( 6 , 1 , 22 ,75 , "RFD")
	
EndIF
	
RestArea( aArea )

Return( NIL )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁPona430Inc		ЁAutorЁLeandro Drumond    Ё Data Ё28/10/2009Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁChamada a AxInclui com Validacao no TudoOk                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA430                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁNIL															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Pona430Inc( cAlias , nReg , nOpcx )
Return( AxInclui( cAlias , nReg , nOpcx , NIL , NIL , NIL , "Pona430TudOk()" ) )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁPona430Alt		ЁAutorЁLeandro Drumond    Ё Data Ё28/10/2009Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁChamada a AxAltera com Validacao no TudoOk                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA430                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁNIL															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Pona430Alt( cAlias , nReg , nOpcx )

Local aAlter := NIL

If RFD->RFD_SISTEM == '1'
	aAlter := {"RFD_DESC"}
EndIf

Return( AxAltera( cAlias , nReg , nOpcx , NIL , aAlter , NIL , NIL , NIL ) ) 

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁPona430Del		ЁAutorЁLeandro Drumond    Ё Data Ё06/11/2009Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁChamada a AxDeleta com Validacao no TudoOk                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA430                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁNIL															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Pona430Del( cAlias , nReg , nOpcx )

IF RFD->RFD_SISTEM == '1'
	MsgAlert( STR0010 , STR0011 ) //"Registros de uso exclusivo do sistema nЦo podem ser deletados." # "AtenГЦo"
	Return(.F.)
EndIf

Return( AxDeleta( cAlias , nReg , nOpcx  ) )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁPona430TudOk	ЁAutorЁLeandro Drumond    Ё Data Ё28/10/2009Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida o Conteudo da Enchoice                               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA430                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁNIL															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Pona430TudOk()

Local lTudoOk	:= .T.

Return( lTudoOk )

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё GeraRFD  Ё Autor Ё Leandro Drumond       Ё Data Ё 04/11/09 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Funcao de processamento da gravacao do RFD                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Processamento do Compatibilizador                          Ё╠╠
╠╠юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function GeraRFD()

Local aRFD   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Preencha a matriz aRCB com os relacionamentos a serem criados. Utilize a mesma ordem indicada na  Ё
//Ё matriz aEstrut                                                             		                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				
If (cPaisLoc == "BRA")

	aEstrut := {"RFD_FILIAL","RFD_CODIGO","RFD_APLIC","RFD_TIPO","RFD_DESC","RFD_SISTEM"}
	
	Aadd(aRFD,{xFilial("RFD"),"01","1","1","INCLUSAO MANUAL"	,"1"})
	Aadd(aRFD,{xFilial("RFD"),"02","1","2","EXCLUSAO MANUAL"	,"1"})
	Aadd(aRFD,{xFilial("RFD"),"03","1","3","REJEICAO AUTOMATICA","1"})
	Aadd(aRFD,{xFilial("RFD"),"04","1","4","INCLUSAO AUTOMATICA","1"})

	dbSelectArea("RFD")
	RFD->( dbSetOrder( RetOrdem( "RFD" , "RFD_FILIAL+RFD_CODIGO+RFD_APLIC+RFD_TIPO" ) ) )

	For i:= 1 To Len(aRFD)
		If !Empty(aRFD[i][2])
			If !RFD->( dbSeek(aRFD[i,1]+aRFD[i,2]+aRFD[i,3]+aRFD[i,4] ) )
				RecLock("RFD",.T.)
				
				For j:=1 To Len(aRFD[i])
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aRFD[i,j])
					EndIf
				Next j
				
				MsUnLock("RFD")
				dbCommit()
			EndIf
		EndIf
	Next i

EndIf

Return(Nil)

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Leandro Drumond  Ё Data Ё28/10/2009Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA430                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Static Function MenuDef()
 
 Local aRotina := {;
							{ STR0004	, "PesqBrw"			, 0 , 1, ,.F. } ,; // "Pesquisar"
	                    	{ STR0005	, "AxVisual"		, 0 , 2 } ,; // "Visualizar"  
	                    	{ STR0006	, "Pona430Inc"		, 0 , 3 } ,; // "Incluir" 
	                     	{ STR0007	, "Pona430Alt"		, 0 , 4 } ,; // "Alterar"     
	                     	{ STR0008	, "Pona430Del"		, 0 , 5 }  ; // "Excluir"
	                    }  
	                    
Return aRotina
