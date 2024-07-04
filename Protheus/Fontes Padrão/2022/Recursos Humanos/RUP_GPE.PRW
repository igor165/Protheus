#Include 'Protheus.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_gpe 

Esta rotina tem como objetivo realizar a criação do RUP do SIGAGPE, ou seja, manter as informações
de dicionário de dados que não são contempladas no UPDDISTR

		
@Author  Rafael Reis
@Since   31/08/2017
@Version 1.0  
@Param		cVersion	- Versão do Protheus 
@Param		cMode		- Modo de execução		- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@Param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente está)
@Param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualização)
@Param		cLocaliz	- Localização (país)	- Ex. "BRA"
@Return ( Nil )

/*/  
//--------------------------------------------------------------------------------------------------

Function RUP_GPE(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)


Local lRet   := .T.
Local aArea 	:= GetArea()
Local aM040		:= {}	//Array com informações do fonte GPEM040
	
Private lAviMisto	:= .F. //Identifica se o GPEM040 está atualizado com o aviso prévio misto.

If cMode == "1"

	If cVersion == "12" .and. cRelFinish == "017" 
	
		//AJSXGPE
		FAtuSX1GPE()
		FAtuSX3GPE()
		FAtuSX5GPE()
		FatuSX6GPE()
		FAtuSX9GPE()
		
		//AJSXAPD
		FAtuSX3APD()
		
		//AJSXAPT
		FAtuSX3APT()
		
		//AJSXCSA
		FAtuSX3CSA()
		
		//AJSXORG
		FAtuSX3ORG()
		
		//AJSXPON
		FAtuSX3PON()
		
		
	Endif

	//Atualiza dados do campo RA_FECREI (Reintegração) e RA_BLOQADM (Bloqueio de admissão)
	If SRA->(ColumnPos( "RA_BLOQADM")) > 0
		FAtuSRAFecRe()
	EndIf

	// Corrige registros de relacionamento indevidos para o México
	If cPaisLoc == "MEX"
		FAtuSX9MEX()
	EndIf

	FAtuSX3ORD()

Endif

Return()

/*/{Protheus.doc} FAtuSX9MEX
Corrige relacionamentos indevidos para o México.
@Author raquel.andrade
@Since 05/08/2021
@Version 1.0
/*/
Static Function FAtuSX9MEX()
Local aAreaSX9  := GetArea("SX9") 
Local lRet		:= .F.

dbSelectArea("SX9")
dbSetOrder(2) //X9_CDOM + X9_DOM

If SX9->(DbSeek("SRASRJ"))
	While AllTrim(SX9->X9_DOM) == "SRJ" .And. AllTrim(SX9->X9_CDOM) == "SRA" .And. !lRet
		If AllTrim(SX9->X9_EXPDOM) == "RJ_CBO" .And. AllTrim(SX9->X9_EXPCDOM) == "RA_CBO" 
			RecLock( "SX9" , .F. )
			SX9->( dbDelete() )
			lRet	:= .T.
			MsUnLock()
		EndIf
		SX9->(DbSkip())
	EndDo
EndIf

RestArea(aAreaSX9)

Return Nil

/*/{Protheus.doc} FAtuSRAFecRe

Realiza alteração da SRA após criação do novo campo RA_BLOQADM, que será utilizado para gravar se o funcionário possui bloqueio de admissão,
o campo RA_FECREI será utilizado apenas para gravar a data de reintegração do funcionário, se exsitir.
@Author Leandro Drumond
@Since 12/02/2019
@Version 1.0
/*/
Static Function FAtuSRAFecRe()
#IFDEF TOP
	TcSqlExec("UPDATE " + RetSqlName("SRA") + " SET RA_BLOQADM = '1', RA_FECREI = '' WHERE RA_FECREI <> '' AND RA_DEMISSA = RA_FECREI AND D_E_L_E_T_ = ''")
#ELSE
	dbSelectArea("SRA")
	SRA->(DbSetOrder(1))
	While !SRA->(Eof())
		If !Empty(SRA->RA_FECREI) .and. !Empty(SRA->RA_DEMISSA) .and. SRA->RA_DEMISSA == SRA->RA_FECREI
			If RecLock("SRA",.F.)
				SRA->RA_BLOQADM := '1'
				SRA->RA_FECREI := ctod('  /  /  ')
				SRA->(msUnlock())
			EndIf
		EndIf
		SRA->(DbSkip())
	End
#ENDIF
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX1GPE

Realiza a atualização do dicionário de dados SX1( Perguntas ) das alterações
do AJSXGPE

@Author Rafael Reis
@Since 31/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX1GPE()

Local aAreaSX1	:=	SX1->( GetArea() )

dbSelectarea("SX1")
SX1->( DBSetOrder( 1 ) )

If SX1->(dbSeek("GPM013    "+"06"))
	If AllTrim(SX1->X1_CNT01) <> "RA_MAT" 
		RecLock("SX1",.F.) 
		SX1->X1_CNT01   := "RA_MAT"   
		SX1->(MsUnlock()) 
	EndIf
	If SX1->(dbSeek("GPM013    "+"05"))
		RecLock("SX1",.F.) 
		SX1->X1_CNT01   := "RA_FILIAL"   
		SX1->(MsUnlock())
	EndIf
	If(SX1->(dbSeek('GPR070    '+"01")))
		If Alltrim(SX1->X1_PERGUNT) <> "Data Ref.Cálc. ?"
			RecLock("SX1",.F.)
			SX1->X1_PERGUNT 		:= "Data Ref.Cálc. ?"
			SX1->(MsUnlock())
		EndIf
	EndIf	
	If(SX1->(dbSeek('GPR090    '+"01")))
		If Alltrim(SX1->X1_PERGUNT) <> "Data Ref.Cálc. ?"
			RecLock("SX1",.F.)
			SX1->X1_PERGUNT 		:= "Data Ref.Cálc. ?"
			SX1->(MsUnlock())
		EndIf
	EndIf	
	If(SX1->(dbSeek('GPM070    '+"02")))
		If Alltrim(SX1->X1_PERGUNT) <> "Data Ref.Cálc. ?"
			RecLock("SX1",.F.)
			SX1->X1_PERGUNT 		:= "Data Ref.Cálc. ?"
			SX1->(MsUnlock())
		EndIf
	EndIf		
EndIf

If (SX1->(dbSeek("GPER670   " + "17")))
	If Alltrim(SX1->X1_F3) == "SRY"
		Reclock("SX1",.F.)
		SX1->X1_F3 = ""
		MsUnlock()
	Endif
Endif


If (SX1->(dbSeek("GPER670   " + "18")))
	If Alltrim(SX1->X1_F3) == "RCJ"
		Reclock("SX1",.F.)
		SX1->X1_F3 = ""
		MsUnlock()
	Endif
Endif



RestArea( aAreaSX1 )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX3PON

Realiza a atualização do dicionário de dados SX3( Campos ) das alterações
do AJSXPON

@Author Rafael Reis
@Since 28/09/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX3PON( )
Local aAreaSX3	:=	SX3->( GetArea() )
Local lDicInDdb := MPDicInDB()

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

If SX3->( DbSeek("R6_ABINTJ") )
	RecLock('SX3', .F.)

		If !lDicInDdb
			SX3->X3_USADO := '€€€€€€€€€€€€€€ '
			SX3->X3_RESERV := '„€'
		Else
			SX3->X3_USADO := X3TreatUso('€€€€€€€€€€€€€€ ')
			SX3->X3_RESERV := X3TreatUso('„€')
		EndIf
		SX3->X3_RELACAO := ''
	MsUnlock()
EndIf

RestArea(aAreaSX3)

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX3ORG

Realiza a atualização do dicionário de dados SX3( Campos ) das alterações
do AJSXORG

@Author Rafael Reis
@Since 28/09/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX3ORG( )
Local aAreaSX3	:=	SX3->( GetArea() )

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

If SX3->( DbSeek("RCL_DFUNC") )
	If SX3->X3_INIBRW <> 'RCLDFuncIni'
		RecLock('SX3', .F.)
			SX3->X3_INIBRW := 'RCLDFuncIni()'
		MsUnlock()
	EndIf
EndIf

RestArea(aAreaSX3)

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX3CSA

Realiza a atualização do dicionário de dados SX3( Campos ) das alterações
do AJSXCSA

@Author Rafael Reis
@Since 28/09/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX3CSA( )
Local aAreaSX3	:=	SX3->( GetArea() )

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

If SX3->( DbSeek("RBH_DIMPOR") )
	If SX3->X3_RELACAO <> 'If(!Inclui, FDesc("RBK",RBH->RBH_IMPORT,"RBK_DESCRI"),"")'
		RecLock('SX3', .F.)
			SX3->X3_RELACAO := 'If(!Inclui, FDesc("RBK",RBH->RBH_IMPORT,"RBK_DESCRI"),"")'
		MsUnlock()
	EndIf
EndIf

If SX3->(DbSeek("RB6_NIVEL")) .AND. SX3->X3_RESERV <> '“€'
	RecLock("SX3",.F.)
		SX3->X3_RESERV := '“€'
	MsUnLock()
EndIf

If SX3->(dbSeek("RB6_COEFIC"))
	If X3TreatUso(SX3->X3_USADO) != "x       x       x       x       x       x    x  x       x       x    x  x      xx       x       x x     x       x       " .Or. ;
		X3TreatUso(SX3->X3_RESERV) != X3TreatUso("  xxxxxx  xxxxxx")
		RecLock("SX3",.F.)
			SX3->X3_USADO := X3TreatUso("x       x       x       x       x       x    x  x       x       x    x  x      xx       x       x x     x       x       ")
			SX3->X3_RESERV := X3TreatUso("  xxxxxx  xxxxxx")
		SX3->(msUnlock())
	EndIf
EndIf

RestArea(aAreaSX3)	

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX3APT

Realiza a atualização do dicionário de dados SX3( Campos ) das alterações
do AJSXAPT

@Author Rafael Reis
@Since 28/09/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX3APT( )
Local aAreaSX3	:=	SX3->( GetArea() )

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

If SX3->( dbSeek("RE0_RZSCFO") )
	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
	EndIf
EndIf

If SX3->( dbSeek("RE0_RAZSOC") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
   		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("RE0_PRDESC") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REA_TPDESC") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REA_PRENOM") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REA_ADRDAN") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REA_OABRDA") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
   		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REA_ADRTEN") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REA_OABRTE") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

//Verifica o conteúdo dos inicializadores padrões do browser da tabela RES
If SX3->( dbSeek("RES_TPDESC") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("RES_PERINO") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

//Verifica o conteúdo dos inicializadores padrões do browser da tabela RE4
If SX3->( dbSeek("RE4_ADVNOM") )
   	If Alltrim(SX3->X3_INIBRW) <> 'fDesc("RD0",RE4->RE4_CODADV,"RD0_NOME")'
   		RecLock("SX3",.F.)
		SX3->X3_INIBRW := 'fDesc("RD0",RE4->RE4_CODADV,"RD0_NOME")'
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("RE4_OAB") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("RE4_ESCNOM") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

//Verifica o conteúdo dos inicializadores padrões do browser da tabela RE9
If SX3->( dbSeek("RE9_TESNOM") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

//Verifica o conteúdo dos inicializadores padrões do browser da tabela REH
If SX3->( dbSeek("REH_TPDESC") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REH_PERINO") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REH_ASSNOM") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REH_RESDES") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

//Verifica o conteúdo dos inicializadores padrões do browser da tabela REL
If SX3->( dbSeek("REL_TPDESC") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

//Verifica o conteúdo dos inicializadores padrões do browser da tabela REM
If SX3->( dbSeek("REM_TPDESC") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REM_RECURS") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

If SX3->( dbSeek("REM_CNTRAZ") )
   	If Alltrim(SX3->X3_INIBRW) <> ''
		RecLock("SX3",.F.)
		SX3->X3_INIBRW := ''
		MsUnLock()
   	EndIf
EndIf

RestArea( aAreaSX3 )

Return()	

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX3APD

Realiza a atualização do dicionário de dados SX3( Campos ) das alterações
do AJSXAPD

@Author Rafael Reis
@Since 28/09/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX3APD( )
Local aAreaSX3	:=	SX3->( GetArea() )

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

If SX3->(DbSeek("QO_MEMO"))
	RecLock("SX3",.F.)
	SX3->X3_RELACAO := 'If(Inclui,"",MSMM(SQO->QO_CODMEM,80))'
	SX3->X3_INIBRW := 'MSMM(SQO->QO_CODMEM,80)'
	MsUnLock()
EndIf

If SX3->(DbSeek("RD0_SENHA"))
	RecLock("SX3",.F.)
	SX3->X3_PICTURE := '@*'
	MsUnLock()
EndIf

If SX3->(DbSeek("RD0_PERMAD"))
	RecLock("SX3",.F.)
	SX3->X3_VALID := 'Pertence(" /1/2")'
	MsUnLock()
EndIf

If SX3->(DbSeek("RBJ_DHABIL"))
	RecLock("SX3",.F.)
	SX3->X3_RELACAO := 'FDesc("RBG",RBJ->RBJ_HABIL,"RBG_DESC",,XFilial("RBG",RBJ->RBJ_FILIAL))'
	SX3->X3_INIBRW := 'FDesc("RBG",RBJ->RBJ_HABIL,"RBG_DESC",,XFilial("RBG",RBJ->RBJ_FILIAL))'
	MsUnLock()
EndIf


RestArea( aAreaSX3 )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX3GPE

Realiza a atualização do dicionário de dados SX3( Campos ) das alterações
do AJSXGPE

@Author Rafael Reis
@Since 31/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX3GPE( )

Local aAreaSX3	:=	SX3->( GetArea() )
Local lDicInDdb := MPDicInDB()

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

If cPaisLoc == "BRA"

	If SX3->(DbSeek("MU_NOMEEMP")) .AND. AllTrim(SX3->X3_RELACAO) <> "fDescRCC('S073',SMU->MU_CODFOR,1,2,17,150,.T.)"
		RecLock("SX3",.F.)
		SX3->X3_RELACAO := "fDescRCC('S073',SMU->MU_CODFOR,1,2,17,150,.T.)"
		MsUnLock()
	EndIf
	
	//Verificar se o ajuste já se encontra na base de dados
	/////////////////RA_LOGRTPD////////////////////
	If SX3->(dbSeek("RA_LOGRTPD")) .And. SX3->X3_RELACAO != 'If(Inclui, "", fDescRCC("S054", SRA->RA_LOGRTP, 1, 4, 5, 20))'
		RecLock("SX3",.F.)
		SX3->X3_RELACAO := 'If(Inclui, "", fDescRCC("S054", SRA->RA_LOGRTP, 1, 4, 5, 20))'
		SX3->(msUnlock())

		/////////////////RE0_INDSUS//////////////////// 
		If SX3->(dbSeek("RE0_INDSUS"))
			RecLock("SX3",.F.)
			SX3->X3_ORDEM := '24'
			SX3->(msUnlock())
		EndIf

		/////////////////RA_CATCNH//////////////////// 
		If SX3->(dbseek("RA_CATCNH"))
			RecLock("SX3",.F.)
			SX3->X3_ORDEM := 'G2'
			SX3->(msUnlock())
		EndIf

		/////////////////RA_UFCNH//////////////////// 
		If SX3->(dbseek("RA_UFCNH"))
			RecLock("SX3",.F.)
			SX3->X3_ORDEM := 'G3'
			SX3->(msUnlock())
		EndIf	


		/////////////////RA_RESERVI////////////////////
		If SX3->(dbSeek("RA_RESERVI"))
			RecLock("SX3",.F.)
			SX3->X3_ORDEM := 'G4'
			SX3->(msUnlock())	
		Endif

		/////////////////R8_INDEOC//////////////////// 
		If SX3->(dbseek("R8_IDEOC"))
			RecLock("SX3",.F.)
			SX3->X3_ORDEM := '61'
			SX3->(msUnlock())
		EndIf
	Endif
	
	// Para casos de Gestao Publica ha os tipos de alteracao EXO e NOM, que nao conseguem ser inseridos na picture 999 anterior.
	If SX3->(dbSeek("RA_TIPOALT"))
		If AllTrim(SX3->X3_PICTURE) != '@!'
			RecLock("SX3", .F.)
			SX3->X3_PICTURE := '@!'
			SX3->(msUnlock())
		Endif
	Endif

	////// RA_DESCCC 
	If SX3->(dbSeek("RA_DESCCC"))
		If "SI3" $ SX3->X3_RELACAO 
			RecLock("SX3",.F.)
			SX3->X3_RELACAO := 'IF(Inclui,"",fDesc("CTT",SRA->RA_CC,"CTT_DESC01",,SRA->RA_FILIAL))'
			SX3->(msUnlock())
		EndIf
	EndIf

	
	If SX3->(dbSeek("RG_IDCMPL"))
		If Upper(Alltrim(SX3->X3_VISUAL)) != "1"
			RecLock("SX3",.F.)
			SX3->X3_VISUAL := "1"
			SX3->(msUnlock())
		EndIf
	EndIf
	
	If SX3->(dbSeek("RCE_DESAFA")) .And. SX3->X3_TAMANHO == 3
		IF !SX3->X3_FOLDER == "5" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "5"
			SX3->(msUnlock())
		Endif
		IF !Empty(SX3->X3_CBOX) .Or. !Empty(SX3->X3_CBOXSPA) .Or. !Empty(SX3->X3_CBOXENG)
			RecLock("SX3",.F.)
			SX3->X3_CBOX := ""
			SX3->X3_CBOXSPA := ""
			SX3->X3_CBOXENG := ""
			SX3->(msUnlock())
		Endif		
		IF !Empty(SX3->X3_VALID)
			RecLock("SX3",.F.)
			SX3->X3_VALID := ''
			SX3->(msUnlock())
		Endif
	Endif
	
	//POSICIONAMENTO DOS CAMPOS DO AVISO NO SINDICATO
	If RCE->(ColumnPos( "RCE_PRJAVT")) > 0
		If SX3->(dbSeek("RCE_DIASAV"))
			IF !SX3->X3_FOLDER == "F" 
				RecLock("SX3",.F.)
				SX3->X3_FOLDER := "F"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RCE_PRJAVT"))
			IF !SX3->X3_FOLDER == "F" 
				RecLock("SX3",.F.)
				SX3->X3_FOLDER := "F"
				SX3->(msUnlock())
			Endif
		Endif
	Else
		If SX3->(dbSeek("RCE_DIASAV"))
			IF !SX3->X3_FOLDER == "5" 
				RecLock("SX3",.F.)
				SX3->X3_FOLDER := "5"
				SX3->(msUnlock())
			Endif
		Endif
	Endif
	
	//Verifica se o GPEM040 está atualizado com o aviso prévio misto.
	aM040 := GetApoInfo("GPEM040.PRX")
	lAviMisto := aM040[4] >= CTOD("07/03/2016")
	
	If lAviMisto
		//ORDEM DOS CAMPOS DO CADASTRO DE AVISO PRÉVIO
		// *** NÃO REMOVER ESTE AJUSTE ATÉ MARÇO/2017 *** //
		//OK
		If SX3->(dbSeek("RFY_TPAVIS"))
			IF !SX3->X3_ORDEM == "03" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "03"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RFY_DTASVP"))
			IF !SX3->X3_ORDEM == "04" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "04"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RFY_DIASAV"))
			IF !SX3->X3_ORDEM == "05" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "05"
				SX3->(msUnlock())
			Endif
		Endif	
		If SX3->(dbSeek("RFY_DAVCUM"))
			IF !SX3->X3_ORDEM == "06" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "06"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RFY_DAVIND"))
			IF !SX3->X3_ORDEM == "07" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "07"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RFY_DTPJAV"))
			IF !SX3->X3_ORDEM == "08" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "08"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RFY_TPRESC"))
			IF !SX3->X3_ORDEM == "09" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "09"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RFY_OBSAV"))
			IF !SX3->X3_ORDEM == "10" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "10"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RFY_TPCAP"))
			IF !SX3->X3_ORDEM == "11" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "11"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RFY_DTCAP"))
			IF !SX3->X3_ORDEM == "12" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "12"
				SX3->(msUnlock())
			Endif
		Endif
		If SX3->(dbSeek("RFY_OBSCAP"))
			IF !SX3->X3_ORDEM == "13" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "13"
				SX3->(msUnlock())
			Endif
		Endif

		//ORDEM DOS CAMPOS DO CALCULO DA RESCISÃO
		If SX3->(dbSeek("RG_TIPORES"))
			IF !SX3->X3_ORDEM == "06" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "06"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_DESCTPR"))
			IF !SX3->X3_ORDEM == "07" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "07"
				SX3->(msUnlock())
			Endif
		Endif	
		
		If SX3->(dbSeek("RG_DTAVISO"))
			IF !SX3->X3_ORDEM == "08" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "08"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_DAVISO"))
			IF !SX3->X3_ORDEM == "09" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "09"
				SX3->(msUnlock())
			Endif
		Endif	

		If SX3->(dbSeek("RG_DAVCUM"))
			IF !SX3->X3_ORDEM == "10" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "10"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_DAVIND"))
			IF !SX3->X3_ORDEM == "11" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "11"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_DATADEM"))
			IF !SX3->X3_ORDEM == "12" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "12"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_DATAHOM"))
			IF !SX3->X3_ORDEM == "13" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "13"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_DTGERAR"))
			IF !SX3->X3_ORDEM == "14" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "14"
				SX3->(msUnlock())
			Endif
		Endif
		
		If SX3->(dbSeek("RG_MEDATU"))
			IF !SX3->X3_ORDEM == "15" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "15"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_DFERVEN"))
			IF !SX3->X3_ORDEM == "16" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "16"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_DFERPRO"))
			IF !SX3->X3_ORDEM == "17" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "17"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_DFERAVI"))
			IF !SX3->X3_ORDEM == "18" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "18"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_NORMAL"))
			IF !SX3->X3_ORDEM == "19" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "19"
				SX3->(msUnlock())
			Endif
		Endif


		If SX3->(dbSeek("RG_DESCANS"))
			IF !SX3->X3_ORDEM == "20" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "20"
				SX3->(msUnlock())
			Endif
		Endif


		If SX3->(dbSeek("RG_SALMES"))
			IF !SX3->X3_ORDEM == "21" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "21"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_SALDIA"))
			IF !SX3->X3_ORDEM == "22" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "22"
				SX3->(msUnlock())
			Endif
		Endif

		If SX3->(dbSeek("RG_SALHORA"))
			IF !SX3->X3_ORDEM == "23" 
				RecLock("SX3",.F.)
				SX3->X3_ORDEM := "23"
				SX3->(msUnlock())
			Endif
		Endif
		
	Endif
	
	//Posiciona os campos do histórico de contrato nas pastas
	If SX3->(dbSeek("RGE_NOMEMP"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif
	If SX3->(dbSeek("RGE_CNPJ"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif
	If SX3->(dbSeek("RGE_CODPAI"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif		
	If SX3->(dbSeek("RGE_LOGRAD"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif		
	If SX3->(dbSeek("RGE_NUMERO"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif		
	If SX3->(dbSeek("RGE_COMPL"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_BAIRRO"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_CODPOS"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif		
	If SX3->(dbSeek("RGE_CIDADE"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_ESTPRO"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_TELEFO"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_BENREN"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_TIPREN"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif		
	If SX3->(dbSeek("RGE_FRMTRB"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_CODRET"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_BEDINI"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_PAEXNI"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif		
	If SX3->(dbSeek("RGE_CODNIF"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_DESCIR"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_PERCIR"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif	
	If SX3->(dbSeek("RGE_DEDINS"))
		IF !SX3->X3_FOLDER == "3" 
			RecLock("SX3",.F.)
			SX3->X3_FOLDER := "3"
			SX3->(msUnlock())
		Endif
	Endif		
	
	//CONVERTIDAS ----------------------------------------------------------------------------------------------------------------------------------------------------------
	
	If SX3->(dbSeek("SRA_MEMOTCF"))
		If SX3->X3_RELACAO <> 'If(inclui,"",   Iif( Empty(SRA->RA_TCFMSG), "" ,MSMM(SRA->RA_TCFMSG,80))  )'
			RecLock("SX3",.F.)
			SX3->X3_RELACAO := 'If(inclui,"",   Iif( Empty(SRA->RA_TCFMSG), "" ,MSMM(SRA->RA_TCFMSG,80))  )'
			SX3->(msUnlock())
		Endif
	Endif

	If SX3->(dbSeek("RAW_PROCES"))
		RecLock("SX3",.F.)
		If SX3->X3_USADO <> "€€€€€€€€€€€€€€ "
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		EndIf
		If SX3->X3_F3 <> 'RCJ'
			SX3->X3_F3 := 'RCJ'
		Endif
		If SX3->X3_BROWSE <> 'S'
			SX3->X3_BROWSE := 'S'
		Endif
		If SX3->X3_VISUAL <> 'A'
			SX3->X3_VISUAL = 'A'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '…€'
			SX3->X3_RESERV = '…€'
		Endif
		SX3->(msUnlock())
	Endif
	
	If SX3->(dbSeek("RAW_SEMANA"))
		RecLock("SX3",.F.)
		If SX3->X3_USADO <> "€€€€€€€€€€€€€€ "
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		EndIf
		If SX3->X3_RELACAO <> 'RCNUMPGINIT()'
			SX3->X3_RELACAO := 'RCNUMPGINIT()'
		Endif
		If SX3->X3_F3 <> 'RCH01'
			SX3->X3_F3 := 'RCH01'
		Endif
		If SX3->X3_BROWSE <> 'S'
			SX3->X3_BROWSE := 'S'
		Endif
		If SX3->X3_VISUAL <> 'A'
			SX3->X3_VISUAL = 'A'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '…€'
			SX3->X3_RESERV = '…€'
		Endif
		SX3->(msUnlock())
	Endif
	
	If SX3->(dbSeek("RAW_ROTEIR"))
		RecLock("SX3",.F.)
		If SX3->X3_USADO <> "€€€€€€€€€€€€€€ "
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		EndIf
		If SX3->X3_F3 <> 'SRY'
			SX3->X3_F3 := 'SRY'
		Endif
		If SX3->X3_BROWSE <> 'S'
			SX3->X3_BROWSE := 'S'
		Endif
		If SX3->X3_VISUAL <> 'A'
			SX3->X3_VISUAL = 'A'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '…€'
			SX3->X3_RESERV = '…€'
		Endif
		SX3->(msUnlock())
	Endif
	
	If SX3->(dbSeek("R3_INTGTAF"))
		RecLock("SX3",.F.)
		If SX3->X3_USADO <> "€€€€€€€€€€€€€€ "
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		EndIf
		If SX3->X3_BROWSE <> 'N'
			SX3->X3_BROWSE := 'N'
		Endif
		If SX3->X3_VISUAL <> 'A'
			SX3->X3_VISUAL = 'A'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '†€'
			SX3->X3_RESERV = '†€'
		Endif
		SX3->(msUnlock())
	Endif
								 													 												 							
	If SX3->(dbSeek("R7_INTGTAF"))
		RecLock("SX3",.F.)
		If SX3->X3_USADO <> "€€€€€€€€€€€€€€ "
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		EndIf
		If SX3->X3_BROWSE <> 'N'
			SX3->X3_BROWSE := 'N'
		Endif
		If SX3->X3_VISUAL <> 'A'
			SX3->X3_VISUAL = 'A'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '†€'
			SX3->X3_RESERV = '†€'
		Endif
		SX3->(msUnlock())
	Endif

	If SX3->(dbSeek("R8_INTGTAF"))
		RecLock("SX3",.F.)
		If SX3->X3_USADO <> "€€€€€€€€€€€€€€ "
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		EndIf
		If SX3->X3_BROWSE <> 'N'
			SX3->X3_BROWSE := 'N'
		Endif
		If SX3->X3_VISUAL <> 'A'
			SX3->X3_VISUAL = 'A'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '†€'
			SX3->X3_RESERV = '†€'
		Endif
		SX3->(msUnlock())
	Endif
						 							
	If SX3->(dbSeek("R8_TPEFDAN"))
		RecLock("SX3",.F.)
		If SX3->X3_USADO <> "€€€€€€€€€€€€€€ "
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		EndIf
		If SX3->X3_BROWSE <> 'N'
			SX3->X3_BROWSE := 'N'
		Endif
		If SX3->X3_VISUAL <> 'V'
			SX3->X3_VISUAL = 'V'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '†€'
			SX3->X3_RESERV = '†€'
		Endif
		SX3->(msUnlock())
	Endif
	
	If SX3->(dbSeek("R8_EFDRETR"))
		RecLock("SX3",.F.)
		If SX3->X3_USADO <> "€€€€€€€€€€€€€€ "
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		EndIf
		If SX3->X3_BROWSE <> 'N'
			SX3->X3_BROWSE := 'N'
		Endif
		If SX3->X3_VISUAL <> 'A'
			SX3->X3_VISUAL = 'A'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '†€'
			SX3->X3_RESERV = '†€'
		Endif
		SX3->(msUnlock())
	Endif

	If SX3->(dbSeek("R8_ORIGALT"))
		RecLock("SX3",.F.)
		If !lDicInDdb
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		Else
			SX3->X3_USADO := X3TreatUso("x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ")
		EndIf
		If SX3->X3_BROWSE <> 'N'
			SX3->X3_BROWSE := 'N'
		Endif
		If SX3->X3_VISUAL <> 'A'
			SX3->X3_VISUAL = 'A'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '†€'
			SX3->X3_RESERV = '†€'
		Endif
		SX3->(msUnlock())
	Endif
	
	If SX3->(dbSeek("R8_NRPRCJU"))
		RecLock("SX3",.F.)
		If SX3->X3_USADO <> "€€€€€€€€€€€€€€ "
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
		EndIf
		If SX3->X3_BROWSE <> 'N'
			SX3->X3_BROWSE := 'N'
		Endif
		If SX3->X3_VISUAL <> 'A'
			SX3->X3_VISUAL = 'A'
		Endif
		If SX3->X3_CONTEXT <> 'R'
			SX3->X3_CONTEXT := 'R'
		Endif
		If SX3->X3_RESERV <> '†€'
			SX3->X3_RESERV = '†€'
		Endif
		SX3->(msUnlock())
	Endif
				
EndIf

If cPaisLoc == "MEX"
   If SX3->(dbSeek("RG_PERIODO"))
	   	If ! AllTrim(SX3->X3_VALID) == 'ExistCpo("RCH",M->RG_PROCES+M->RG_PERIODO)'
			RecLock("SX3",.F.)
			SX3->X3_VALID := 'ExistCpo("RCH",M->RG_PROCES+M->RG_PERIODO)'
			SX3->(msUnlock())
		EndIf
	EndIf   	
EndIf


////// RGB_DTREF
If SX3->(dbSeek("RGB_DTREF"))
	If Empty(SX3->X3_RELACAO) .Or. Upper(AllTrim(SX3->X3_RELACAO)) == 'RCDTREFINIT()'
		RecLock("SX3",.F.)
		SX3->X3_RELACAO := 'cToD("//")'
		SX3->(msUnlock())
	EndIf
EndIf

////// Q3_CARGO
If SX3->(dbSeek("Q3_CARGO"))
	If AllTrim(SX3->X3_RELACAO) == 'GetSX8Num("SQ3","Q3_CARGO")'
		RecLock("SX3",.F.)
		SX3->X3_RELACAO := ''
		SX3->(msUnlock())	
	EndIf
	If AllTrim(SX3->X3_PICTURE) ==  '99999'
		RecLock("SX3",.F.)
		SX3->X3_PICTURE := '@!'
		SX3->(msUnlock())
	EndIf

EndIf

////// RA5_CARGO
If SX3->(dbSeek("RA5_CARGO"))
	If ! AllTrim(SX3->X3_PICTURE) ==  '@!'
		RecLock("SX3",.F.)
		SX3->X3_PICTURE := '@!'
		SX3->(msUnlock())
	EndIf
EndIf

////// RA8_CARGO
If SX3->(dbSeek("RA8_CARGO"))
	If ! AllTrim(SX3->X3_PICTURE) ==  '@!'
		RecLock("SX3",.F.)
		SX3->X3_PICTURE := '@!'
		SX3->(msUnlock())
	EndIf
EndIf

////// QG_CODFUN
If SX3->(dbSeek("QG_CODFUN"))
	If ! AllTrim(SX3->X3_PICTURE) ==  '@!'
		RecLock("SX3",.F.)
		SX3->X3_PICTURE := '@!'
		SX3->(msUnlock())
	EndIf
EndIf

////// RJ_CARGO
If SX3->(dbSeek("RJ_CARGO"))
	If ! AllTrim(SX3->X3_PICTURE) ==  '@!'
		RecLock("SX3",.F.)
		SX3->X3_PICTURE := '@!'
		SX3->(msUnlock())
	EndIf
EndIf

////// R8_STATUS
If SX3->(dbSeek("R8_STATUS"))
	If AllTrim(SX3->X3_VISUAL) !=  'A'
		RecLock("SX3",.F.)
		SX3->X3_VISUAL := 'A'
		SX3->(msUnlock())
	EndIf
EndIf

If SX3->(DbSeek("RG_PDRESC" ))
	RecLock("SX3",.F.)
		If !lDicInDdb
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
			SX3->X3_RESERV  := "„€"
		Else
			SX3->X3_USADO := X3TreatUso("x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ")
			SX3->X3_RESERV := X3TreatUso("x    x  x       ")
		EndIf
	SX3->(MsUnlock())
EndIf


If SX3->(DbSeek("RK_VALORAR" ))
	RecLock("SX3",.F.)
		If !lDicInDdb
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
			SX3->X3_RESERV  := "”€"
		Else
			SX3->X3_USADO := X3TreatUso("  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxxx x     ")
			SX3->X3_RESERV := X3TreatUso("  xxxxxx  xxxxxx")
		EndIf
	SX3->(MsUnlock())
EndIf

If SX3->(DbSeek("RG1_DFIMPG" ))
	RecLock("SX3",.F.)
		If !lDicInDdb
			SX3->X3_USADO := "€€€€€€€€€€€€€€ "
			SX3->X3_RESERV  := "”€"
		Else
			SX3->X3_USADO := X3TreatUso("  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxx  xxxxxxx x     ")
			SX3->X3_RESERV := X3TreatUso("  xxxxxx  xxxxxx")
		EndIf
	SX3->(MsUnlock())
EndIf

		
RestArea( aAreaSX3 )
				
Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX5GPE

Realiza a atualização do dicionário de dados SX5( Tabelas Genéricas )
das alterações do AJSXGPE
@Author Rafael Reis
@Since 31/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX5GPE()

Local aAreaSX5	:=	SX5->( GetArea() )

dbSelectArea("SX5")
SX5->(dbSetOrder(1))

If cPaisLoc == "BRA"
	If dbSeek(xFilial()+"38"+"2C")
		If Alltrim(SX5->X5_DESCRI) <> "TRABALHADOR RURAL     / TRANSFERENCIA"
			RecLock("SX5",.F.) 
			SX5->X5_DESCRI := "TRABALHADOR RURAL     / TRANSFERENCIA"
			MsUnlock()
		EndIf
	EndIf
	
	/*Ajustes pro chamado TUORZT*/
	AjSxRCB()

	dbSelectArea("SX5")
	dbSetOrder(1)
	If dbSeek(xFilial()+"R5"+"A")
		If Upper(Alltrim(SX5->X5_DESCRI)) <> "ANO(S)"
			RecLock("SX5",.F.) 
			SX5->X5_DESCRI := "Ano(s)"
			MsUnlock()
		EndIf
	EndIf

	If dbSeek(xFilial()+"R5"+"D")
		If Upper(Alltrim(SX5->X5_DESCRI)) <> "DIA(S)"
			RecLock("SX5",.F.) 
			SX5->X5_DESCRI := "Dia(s)"
			MsUnlock()
		EndIf
	EndIf

	If dbSeek(xFilial()+"R5"+"H")
		If Upper(Alltrim(SX5->X5_DESCRI)) <> "HORA(S)"
			RecLock("SX5",.F.) 
			SX5->X5_DESCRI := "Hora(s)"
			MsUnlock()
		EndIf
	EndIf

	If dbSeek(xFilial()+"R5"+"M")
		If Upper(Alltrim(SX5->X5_DESCRI)) <> "MES(S)"
			RecLock("SX5",.F.) 
			SX5->X5_DESCRI := "Mes(s)"
			MsUnlock()
		EndIf
	EndIf
EndIf

RestArea (aAreaSX5)

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX6GPE

Realiza a atualização do dicionário de dados SX6( Parâmetros )
das alterações do AJSXGPE
@Author Eduardo Martinez
@Since 31/07/2018
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX6GPE()

Local aAreaSX6 := GetArea("SX6") 

DbSelectArea("SX6")
DbSetOrder(1)
If DbSeek(xFilial("SX6") + 'MV_DIAANFE')
	If SX6->X6_VALID != 'Val(M->X6_CONTEUD) >= 0 .AND. Val(M->X6_CONTSPA) >= 0 .AND. Val(M->X6_CONTSPA) >= 0'
		Reclock("SX6",.F.)
		SX6->X6_VALID := 'Val(M->X6_CONTEUD) >= 0 .AND. Val(M->X6_CONTSPA) >= 0 .AND. Val(M->X6_CONTSPA) >= 0'
		MsUnlock()
	EndIf
Endif

RestArea(aAreaSX6)

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuSX9GPE

Realiza a atualização do dicionário de dados SX9( Relacionamento entre Arquivos )
das alterações do AJSXGPE

@Author Rafael Reis
@Since 31/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuSX9GPE()

Local aAreaSX9 := GetArea("SX9") 

dbSelectArea("SX9")
dbSetOrder(2) //X9_CDOM + X9_DOM

If cPaisLoc == "BRA"
	SX9->(dbSeek("SRARFO"))
	While SX9->X9_DOM == "RFO" .AND. SX9->X9_CDOM == "SRA"
		If Alltrim(SX9->X9_EXPDOM) == "RFO_CODIGO"
			RecLock("SX9",.F.)
			DbDelete()
			SX9->( MsUnlock() )
		Endif
		dbSkip()
		Loop
	EndDo
EndIf

RestArea(aAreaSX9)

Return()

/*/{Protheus.doc} AjSxRCB
Ajustes necessários pro chamado TUORZT
@author PHILIPE.POMPEU
@since 24/03/2016
@version P12
@return ${return}, ${return_description}
/*/
Static Function AjSxRCB()
	Local aAreas	:= {SXB->(GetArea()),SX3->(GetArea()),GetArea()}
	Local cNomeXB	:= 'S054BR'
	Local lAtualiza := .F.

	If!(SXB->(dbSeek(cNomeXB)))
		lAtualiza := .T.
	EndIf

	If(lAtualiza)
		/*Necessário para que sejam atualizadas todas as filiais de 1x só.*/
		
		#IFDEF TOP
			TcSqlExec("UPDATE "+ RetSqlName("RCB") +" SET RCB_PESQ = '1' WHERE RCB_CODIGO IN ('S054','S049') AND RCB_CAMPOS LIKE 'DESCRICAO%' AND D_E_L_E_T_ = '' AND RCB_PESQ <> '1'")
		#ELSE
			dbSelectArea("RCB")
			RCB->(DbSetOrder(1))
			While !RCB->(Eof())
				If Alltrim(RCB->RCB_CODIGO) $ ('S054','S049') .And. RCB->RCB_PESQ <> '1' .And. 'DESCRICAO' $ RCB->RCB_CAMPOS 
					If RecLock("RCB",.F.)
						RCB->RCB_PESQ := '1'
						RCB->(msUnlock())
					EndIf
				EndIf
				RCB->(DbSkip())
			End
		#ENDIF
		
	
	EndIf

	aEval(aAreas,{|x|RestArea(x)})

Return Nil

Static Function FAtuSX3ORD( )
Local aAreaSX3	:=	SX3->( GetArea() )

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

If cPaisLoc == "BRA"

	If SX3->(dbSeek("RC3_ORIGEM")) .And. SX3->X3_ORDEM <> "02" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "02"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_CODIGO")) .And. SX3->X3_ORDEM <> "03" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "03"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_DESCR")) .And. SX3->X3_ORDEM <> "04" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "04"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_SEQFOR")) .And. SX3->X3_ORDEM <> "05" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "05"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_SEQPAI")) .And. SX3->X3_ORDEM <> "06" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "06"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_TIPO")) .And. SX3->X3_ORDEM <> "07" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "07"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_TPRESU")) .And. SX3->X3_ORDEM <> "08" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "08"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_RESULT")) .And. SX3->X3_ORDEM <> "09" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "09"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_RESM")) .And. SX3->X3_ORDEM <> "10" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "10"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_OPERA1")) .And. SX3->X3_ORDEM <> "11" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "11"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_TPFM01")) .And. SX3->X3_ORDEM <> "12" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "12"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_FORM01")) .And. SX3->X3_ORDEM <> "13" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "13"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_FOR01M")) .And. SX3->X3_ORDEM <> "14" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "14"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_CODIGO")) .And. SX3->X3_ORDEM <> "03" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "03"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_OPERA2")) .And. SX3->X3_ORDEM <> "15" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "15"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_TPFM02")) .And. SX3->X3_ORDEM <> "16" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "16"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_FORM02")) .And. SX3->X3_ORDEM <> "17" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "17"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_FOR02M")) .And. SX3->X3_ORDEM <> "18" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "18"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_OPERA3")) .And. SX3->X3_ORDEM <> "19" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "19"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_RESOU1")) .And. SX3->X3_ORDEM <> "20" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "20"
		SX3->(msUnlock())
	EndIf

	If SX3->(dbSeek("RC3_RESOU2")) .And. SX3->X3_ORDEM <> "21" 
		RecLock("SX3",.F.)
		SX3->X3_ORDEM := "21"
		SX3->(msUnlock())
	EndIf

EndIf

RestArea(aAreaSX3)
Return
