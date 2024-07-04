#INCLUDE "plsua560.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#DEFINE VL_RECONHE 15 // Posicao no array aReg552 do campo "VL_RECONHE" (Valor Reconhecido)
STATIC bCodLayPLS := .F.
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSUA560   Ё Autor Ё Nayland             Ё Data Ё 02.12.11 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Gera o arquivo PTU 560...                                  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSUA560()
Local oDlg
Local aOPC := {}
Local nRadio := 0
Local oRadio
Local bBlock := { |x| Iif( ValType( x ) == 'U', nRadio, nRadio:=x ) }

PRIVATE oTempR61
PRIVATE oTempR62
PRIVATE oTempR67
PRIVATE oTempR68
PRIVATE oTempR69

aAdd( aOPC, STR0001 ) //"Executora"
aAdd( aOPC, STR0002 ) //"Origem" 
aAdd( aOPC, "Reembolso - Or.Prest."  )  
aAdd( aOPC, "Reembolso - Or.Benef." ) 

DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 245,205 OF oDlg PIXEL //"A560"
	@ 4, 5 TO 80,100 LABEL  STR0004 OF oDlg PIXEL //" Selecione "
	oRadio := TRadMenu():New( 12, 10, aOPC, bBlock, oDlg, , NIL, , , , , ,80 ,10 )
	@ 110,33 BUTTON "&Executar" SIZE 32,10 PIXEL ACTION Pl560Exec(nRadio) 
	@ 110,68 BUTTON "&Sair"     SIZE 32,10 PIXEL ACTION oDlg:End()
ACTIVATE MSDIALOG oDlg CENTER

Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSUA560   Ё Autor Ё Nayland             Ё Data Ё 02.12.11 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Gera o arquivo PTU 560 A PARTIR DO BRJ                     Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function Pl560Exec(nRadio)

If nRadio == 1    
	PL560BTO()//Executora
ElseIf nRadio == 2
	PL560BRJ()//Origem
ElseIf nRadio == 3
    PL560BRJ(.T.)
ElseIf nRadio == 4 
	PL560BTO(.T.)
Endif

Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSUA560   Ё Autor Ё Nayland             Ё Data Ё 02.12.11 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Gera o arquivo PTU 560 A PARTIR DO BRJ                     Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PL560BRJ(lReemb)
LOCAL cPLSFiltro  := ""
PRIVATE cCadastro := STR0004 //"Ajius ExportaГЦo"
PRIVATE aRotina   := {  { STR0005, 'AxPesqui'		, 0, K_Pesquisar  },; //"Pesquisar"
						{ STR0006, 'PLSUA560VS'		, 0, K_Visualizar },; //"Visualizar"
						{ STR0007, 'PLSUA560GE(0)'	, 0, K_Incluir    },; //"Exportar"
						{ STR0008, 'PLSUA560GE(1)'	, 0, K_Excluir    } } //"Cancelar"
PRIVATE cMarcaBRJ := GetMark()    
PRIVATE cGerPtu   := GetNewPar("MV_GERPTU","0") //Parametro = 0 - Criado para versao 4.1B, NAO GERA TITULO CONTESTACAO / 1 - GERA TITULO CONTESTACAO
PRIVATE nSeqImp   := 0 
DEFAULT lReemb:= .F.

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё cGerPtu = "0" Titulo de Contestacao foi criado no Lote de Pagto(PLSA470)      Ё
//Ё cGerPtu = "1" Titulo de Contestacao sera criado no momento da geracao do A560 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' "
    cPLSFiltro += " AND (((BRJ_NUMSE2 <> ' ' AND BRJ_PRESE2 <> ' ' AND BRJ_TIPSE2 <> ' ') OR (BRJ_TPCOB = '1' AND BRJ_PREE2N <> ' ' AND BRJ_NUME2N <> ' ') AND BRJ_GERPTU = '0')"
	cPLSFiltro += " OR ((BRJ_PREFIX <> ' ' AND BRJ_NUMTIT <> ' ') OR (BRJ_TPCOB = '1' AND BRJ_PRENDC <> ' ' AND BRJ_NRNDC <> ' ') AND BRJ_GERPTU = '1' ))"
	cPLSFiltro += " AND D_E_L_E_T_ = ' '"


If lReemb
	cPLSFiltro += " AND BRJ_TIPLOT = '2' "
Else
	cPLSFiltro += " AND BRJ_TIPLOT <> '2' "
EndIf  

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona a area														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("BRJ")
SET FILTER TO &cPLSFiltro
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Browse																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BRJ->(MarkBrow("BRJ","BRJ_OK",nil,nil,,cMarcaBRJ,nil,,,,"PLSUA560MR()"))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona a area														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("BRJ")
SET FILTER TO
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina														     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSUA560GE Ё Autor Ё Nayland             Ё Data Ё 02.12.11 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Gera os arquivos de exportacao/cancela do ajius 			  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSUA560GE(nTp)
LOCAL aRet
LOCAL nFor
LOCAL lSeg		:= .T.
LOCAL lCan		:= .F.
LOCAL lRet		:= .T.
LOCAL aOK		:= {}
LOCAL cPerg		:= "PLU560    "
LOCAL aVetor	:={}                                       
LOCAL cQuery	:= "" 
LOCAL lCancBD6 	:= .F.   
Local cOpePad   := PlsIntPad()
Local cBanco    := Alltrim(Upper(TCGetDb()))
Local cChvSE1   := ""
Local cChvSE1Aba:= ""
Local cChvSE11  := ""
Local cChvSE12  := ""
Local cChvSE13  := ""
Local cChvSE14  := ""

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pergunte somente se nao for cancelar									 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nTp == 0 //Exportar
	lRet := Pergunte(cPerg,.T.)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processamento															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lRet
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё BRJ																		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		B2A->( DbSetOrder(1) ) //B2A_FILIAL + B2A_OPEDES + B2A_NUMTIT
		BRJ->( DbSetOrder(1) ) //BRJ_FILIAL + BRJ_CODIGO

		cQryBRJ := ChangeQuery("SELECT * FROM " + RetSqlName("BRJ") + " WHERE BRJ_FILIAL = '" + xFilial("BRJ") + "' AND BRJ_OK = '" +cMarcaBRJ+ "' AND D_E_L_E_T_ = ' '")
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryBRJ),"TBRJ",.F.,.T.)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё While TBRJ																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Do While !TBRJ->( Eof() )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Cancelamento															 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If nTp == 1
					If B2A->( MsSeek( xFilial("B2A")+TBRJ->(BRJ_OPEORI+BRJ_NUMFAT) ) )
						If !B2A->B2A_TPARQ $ "2,3"
							While !B2A->( Eof() ) .And. B2A->(B2A_FILIAL+B2A_OPEDES+B2A_NUMTIT) == xFilial("B2A")+TBRJ->(BRJ_OPEORI+BRJ_NUMFAT)
								B2A->( RecLock("B2A", .F.) )
									B2A->( dbDelete() )
								B2A->( MsUnlock() )
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Skip																	 Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								B2A->( DbSkip() )
								lCan := .T.
							EndDo
						Else
							MsgStop(STR0017+TBRJ->BRJ_NUMFAT+STR0018)//"Existe importaГЦo para a fatura ( "+######+" ), primeiro cancele a importaГЦo!"
						EndIf
					Else
						MsgStop(STR0015+TBRJ->BRJ_NUMFAT+STR0016)//"Fatura ( "+#######+" ), ainda nao foi exportada!"
					EndIf
				Else
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Processamento															 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If lSeg   
						BRJ->(DbGoto(TBRJ->R_E_C_N_O_))					
						aRet := PL560ORI()
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Retorno																	 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If Len(aRet) > 0
							If aRet[1]
								AaDd(aOK,{TBRJ->(BRJ_OPEORI+"-"+TBRJ->BRJ_NOMORI),STR0006,aRet[2]}) //"Arquivo Gerado"
							Else
								If Len(aRet[2]) > 0
									AaDd(aOK,{TBRJ->(BRJ_OPEORI+"-"+TBRJ->BRJ_NOMORI),STR0007,""}) //"Nao foi possivel gerar. Motivo:"
									For nFor := 1 To Len(aRet[2])
										AaDd(aOK,{"",aRet[2,nFor,1]+"-"+aRet[2,nFor,2] ,""})
									Next
								EndIf
							Endif
						EndIf
					EndIf
				EndIf
			TBRJ->( DbSkip() )
		Enddo
		TBRJ->(dbCloseArea())
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Len Matriz																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Len(aOK) > 0
		PLSCRIGEN(aOK,{ {STR0011,"@C",150},{STR0012,"@C",250},{STR0013,"@C",060} }, STR0014) //"Operadora Origem"###"Status"###"Arquivo Gerado"###"  Resumo " 
	Endif
Else //Cancelar
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Campos criados para PTU 4.1B											 Ё
	//Ё Validacao: Se os campos nao existirem ou nao estao populados se trata    Ё
	//Ё de um PTU anterior a versao 4.1B e realizara a exclusao do SE1 mantendo  Ё
	//Ё o legado caso tenha AB-, sendo que no PTU 4.1B nao tera mais AB-		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды          
	If BRJ->BRJ_GERPTU == "0"
			
		Do Case
			Case BRJ->BRJ_NIV550=='3'
				cMsgNiv := STR0022 //parcial
			Case BRJ->BRJ_NIV550=='5'
				cMsgNiv := STR0025 //integral
			Case BRJ->BRJ_NIV550=='7' 
				cMsgNiv := STR0021 //complementar
			OtherWise
				cMsgNiv := STR0025+"/"+STR0022 //integral/parcial
		EndCase            

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Cancelamento - Titulo de abatimento fatura								 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BRJ->BRJ_TPCOB == '2'
			If BRJ->BRJ_NIV550 $ '3,5'    
				If BRJ->BRJ_ARQPAR == "2"
					cChvSE1 := Alltrim(BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP))
				Else
					cChvSE1 := Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))
				EndIf	
			ElseIf BRJ->BRJ_NIV550 == '7' 
				cChvSE1 := Alltrim(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))
			EndIf
			
			If Empty(cChvSe1)     
				MsgInfo(STR0020 + cMsgNiv + STR0023,STR0024)//"Cancelamento " +  cMsgNiv + " jА efetuado ou ainda nЦo foi exportado o A560!" , "Aviso"
				Return .F.
			EndIf
		
			SE1->( DbSetOrder(1) )
			If SE1->( DbSeek(xFilial("SE1")+cChvSE1))
		
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
		       		     	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			             	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
		       		     	{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
				          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
		
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao
				lCan := .T.
			EndIf	    
		EndIf	    
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Cancelamento - Titulo de abatimento NDC									 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BRJ->BRJ_TPCOB == '1'
		
			If BRJ->BRJ_NIV550 $ '3,5'
				cChvSE1 := Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))
			ElseIf BRJ->BRJ_NIV550 == '7'
				cChvSE1 := Alltrim(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))
			EndIf
			
			If Empty(cChvSe1) 
				MsgInfo(STR0020 + cMsgNiv + STR0023,STR0024)//"Cancelamento " +  "complementar" + "parcial" + " jА efetuado ou ainda nЦo foi exportado o A560!" + "Aviso"
				Return .F.
			EndIf
			
			If SE1->( DbSeek(xFilial("SE1")+cChvSE1))
			
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
		       		     	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			             	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
		       		     	{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
				          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
		
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao   
				lCan := .T.
			EndIf
		EndIf  
		
		If BRJ->BRJ_TPCOB == '3'
			
			If BRJ->BRJ_NIV550 $ '3,5'     
			
           		If BRJ->BRJ_ARQPAR == "2"
					cChvSE11 := Alltrim(BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP))  
					cChvSE12 := Alltrim(BRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+BRJ_NP2TIP))
				Else
					cChvSE11 := Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))
					cChvSE12 := Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))
				EndIf
			
			ElseIf BRJ->BRJ_NIV550 == '7'

				cChvSE11 := Alltrim(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))
				cChvSE12 := Alltrim(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))

			EndIf
			
			If Empty(cChvSe11) .And. Empty(cChvSe12)
				MsgInfo(STR0020 + cMsgNiv + STR0023,STR0024)//"Cancelamento " +  cMsgNiv + " jА efetuado ou ainda nЦo foi exportado o A560!" , "Aviso"
				Return .F.
			EndIf

			If !Empty(cChvSE11) .And. SE1->( DbSeek(xFilial("SE1")+cChvSE11))
		
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
		       		 	    	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			            	 	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
		       		     		{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
					          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
		
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao
				lCan := .T.
			EndIf	    

			If !Empty(cChvSE12) .And. SE1->( DbSeek(xFilial("SE1")+cChvSE12))
		
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
		       		 	    	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			            	 	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
		       		     		{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
					          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
		
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao
				lCan := .T.
			EndIf

		EndIf//BRJ->BRJ_TPCOB == '3'
		
		If lCan 	                                                                     
			MsgInfo(STR0026,STR0024)
		Else
			MsgInfo(STR0027,STR0024)
		Endif   
		
		nSeqImp := BRJ->BRJ_CODIGO
        //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Reembolso                           									 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  BRJ->BRJ_TIPLOT == "2"    
	  		cUpdBD6 := " UPDATE " + RetSqlName("B7R") + " SET "  
	  		cUpdBD6 += " B7R_CONPRE = ' ',"
			cUpdBD6 += " B7R_CONTIT = ' ',"
			cUpdBD6 += " B7R_CONPAR = ' ',"
			cUpdBD6 += " B7R_CONTIP = ' '"      
			
			cUpdBD6 += " WHERE B7R_FILIAL = '" + xFilial("B7R") + "' AND B7R_CODBRJ = '" + nSeqImp + "' AND "  
			If BRJ->BRJ_NIV550 $ '3,5' 
				If BRJ->BRJ_ARQPAR == "2"
					cUpdBD6 += " B7R_CONPRE = '" + BRJ->BRJ_FP2PRE + "' AND "
					cUpdBD6 += " B7R_CONTIT = '" + BRJ->BRJ_FP2TIT + "' AND "
					cUpdBD6 += " B7R_CONPAR = '" + BRJ->BRJ_FP2PAR + "' AND "
					cUpdBD6 += " B7R_CONTIP = '" + BRJ->BRJ_FP2TIP + "' AND " 
				Else
					cUpdBD6 += " B7R_CONPRE = '" + BRJ->BRJ_PREFIX + "' AND "
					cUpdBD6 += " B7R_CONTIT = '" + BRJ->BRJ_NUMTIT + "' AND "
					cUpdBD6 += " B7R_CONPAR = '" + BRJ->BRJ_PARCEL + "' AND "
					cUpdBD6 += " B7R_CONTIP = '" + BRJ->BRJ_TIPTIT + "' AND "
				EndIf
			ElseIf BRJ->BRJ_NIV550 == '7'
				cUpdBD6 += " B7R_CONPRE = '" + BRJ->BRJ_CFTPRE + "' AND "
				cUpdBD6 += " B7R_CONTIT = '" + BRJ->BRJ_CFTTIT + "' AND "
				cUpdBD6 += " B7R_CONPAR = '" + BRJ->BRJ_CFTPAR + "' AND "
				cUpdBD6 += " B7R_CONTIP = '" + BRJ->BRJ_CFTTIP + "' AND " 
			EndIf
			
			cUpdBD6 += "D_E_L_E_T_ = ' '" 
			TCSQLEXEC(cUpdBD6)
	
			If SubStr(cBanco,1,6) == "ORACLE"
				TCSQLEXEC("COMMIT")
			EndIf		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Importacao normal                   									 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Else
	        cUpdBD6 := "UPDATE " + RetSqlName("BD6") + " SET"
			
			If BRJ->BRJ_TPCOB == "1"
				cUpdBD6 += " BD6_NDCPRE = ' ',"
				cUpdBD6 += " BD6_NDCTIT = ' ',"
				cUpdBD6 += " BD6_NDCPAR = ' ',"
				cUpdBD6 += " BD6_NDCTIP = ' '"
			ElseIf BRJ->BRJ_TPCOB == "2"
				cUpdBD6 += " BD6_CONPRE = ' ',"
				cUpdBD6 += " BD6_CONTIT = ' ',"
				cUpdBD6 += " BD6_CONPAR = ' ',"
				cUpdBD6 += " BD6_CONTIP = ' '"
			ElseIf BRJ->BRJ_TPCOB == "3"
				cUpdBD6 += " BD6_NDCPRE = ' ',"
				cUpdBD6 += " BD6_NDCTIT = ' ',"
				cUpdBD6 += " BD6_NDCPAR = ' ',"
				cUpdBD6 += " BD6_NDCTIP = ' ',"
				cUpdBD6 += " BD6_CONPRE = ' ',"
				cUpdBD6 += " BD6_CONTIT = ' ',"
				cUpdBD6 += " BD6_CONPAR = ' ',"
				cUpdBD6 += " BD6_CONTIP = ' '"
			EndIf
			
			cUpdBD6 += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND BD6_SEQIMP = '" + nSeqImp + "' AND BD6_CODOPE = '" + cOpePad +"' AND BD6_GUIORI <> ' ' AND "
	        
			If BRJ->BRJ_TPCOB == "1"
				If BRJ->BRJ_NIV550 == '3,5'
					cUpdBD6 += " BD6_NDCPRE = '" + BRJ->BRJ_PRENDC + "' AND "
					cUpdBD6 += " BD6_NDCTIT = '" + BRJ->BRJ_NUMNDC + "' AND "
					cUpdBD6 += " BD6_NDCPAR = '" + BRJ->BRJ_PARNDC + "' AND "
					cUpdBD6 += " BD6_NDCTIP = '" + BRJ->BRJ_TIPNDC + "' AND " 
				ElseIf BRJ->BRJ_NIV550 == '7'
					cUpdBD6 += " BD6_NDCPRE = '" + BRJ->BRJ_CNDPRE + "' AND "
					cUpdBD6 += " BD6_NDCTIT = '" + BRJ->BRJ_CNDTIT + "' AND "
					cUpdBD6 += " BD6_NDCPAR = '" + BRJ->BRJ_CNDPAR + "' AND "
					cUpdBD6 += " BD6_NDCTIP = '" + BRJ->BRJ_CNDTIP + "' AND " 
				EndIf
			ElseIf BRJ->BRJ_TPCOB == "2"
				If BRJ->BRJ_NIV550 $ '3,5'  
					If BRJ->BRJ_ARQPAR == "2"
						cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_FP2PRE + "' AND "
						cUpdBD6 += " BD6_CONTIT = '" + BRJ->BRJ_FP2TIT + "' AND "
						cUpdBD6 += " BD6_CONPAR = '" + BRJ->BRJ_FP2PAR + "' AND "
						cUpdBD6 += " BD6_CONTIP = '" + BRJ->BRJ_FP2TIP + "' AND "
					Else
						cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_PREFIX + "' AND "
						cUpdBD6 += " BD6_CONTIT = '" + BRJ->BRJ_NUMTIT + "' AND "
						cUpdBD6 += " BD6_CONPAR = '" + BRJ->BRJ_PARCEL + "' AND "
						cUpdBD6 += " BD6_CONTIP = '" + BRJ->BRJ_TIPTIT + "' AND " 
	                EndIf
	
				ElseIf BRJ->BRJ_NIV550 == '7'
					cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_CFTPRE + "' AND "
					cUpdBD6 += " BD6_CONTIT = '" + BRJ->BRJ_CFTTIT + "' AND "
					cUpdBD6 += " BD6_CONPAR = '" + BRJ->BRJ_CFTPAR + "' AND "
					cUpdBD6 += " BD6_CONTIP = '" + BRJ->BRJ_CFTTIP + "' AND " 
	
	        	EndIf
			ElseIf BRJ->BRJ_TPCOB == "3"
				If BRJ->BRJ_NIV550 $ '3,5'
					
					If BRJ->BRJ_ARQPAR == "2"	
						If !Empty(BRJ->BRJ_FP2TIT)
							cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_FP2PRE+ "' AND BD6_CONTIT = '" + BRJ->BRJ_FP2TIT + "' AND BD6_CONPAR = '" + BRJ->BRJ_FP2PAR + "' AND BD6_CONTIP = '" + BRJ->BRJ_FP2TIP + "' AND "
						EndIf
						If !Empty(BRJ->BRJ_NP2TIT)
							cUpdBD6 += " BD6_NDCPRE = '" + BRJ->BRJ_NP2PRE + "' AND BD6_NDCTIT = '" + BRJ->BRJ_NP2TIT + "' AND BD6_NDCPAR = '" + BRJ->BRJ_NP2PAR + "' AND BD6_NDCTIP = '" + BRJ->BRJ_NP2TIP + "' AND "
						EndIf
					Else
						If !Empty(BRJ->BRJ_NUMTIT)
							cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_PREFIX + "' AND BD6_CONTIT = '" + BRJ->BRJ_NUMTIT + "' AND BD6_CONPAR = '" + BRJ->BRJ_PARCEL + "' AND BD6_CONTIP = '" + BRJ->BRJ_TIPTIT + "' AND "
						EndIf
						If !Empty(BRJ->BRJ_NUMNDC)
							cUpdBD6 += " BD6_NDCPRE = '" + BRJ->BRJ_PRENDC + "' AND BD6_NDCTIT = '" + BRJ->BRJ_NUMNDC + "' AND BD6_NDCPAR = '" + BRJ->BRJ_PARNDC + "' AND BD6_NDCTIP = '" + BRJ->BRJ_TIPNDC + "' AND "
						EndIf
					EndIf	
				ElseIf BRJ->BRJ_NIV550 == '7'
					If !Empty(BRJ->BRJ_CFTTIT)
						cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_CFTPRE + "' AND BD6_CONTIT = '" + BRJ->BRJ_CFTTIT + "' AND BD6_CONPAR = '" + BRJ->BRJ_CFTPAR + "' AND BD6_CONTIP = '" + BRJ->BRJ_CFTTIP + "' AND "
					EndIf
					If !Empty(BRJ->BRJ_CNDTIT)
						cUpdBD6 += " BD6_NDCPRE = '" + BRJ->BRJ_CNDPRE + "' AND BD6_NDCTIT = '" + BRJ->BRJ_CNDTIT + "' AND BD6_NDCPAR = '" + BRJ->BRJ_CNDPAR + "' AND BD6_NDCTIP = '" + BRJ->BRJ_CNDTIP + "' AND "
					EndIf
				EndIf
			EndIf
			
			cUpdBD6 += "D_E_L_E_T_ = ' '" 
			TCSQLEXEC(cUpdBD6)
	
			If SubStr(cBanco,1,6) == "ORACLE"
				TCSQLEXEC("COMMIT")
			EndIf
        EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Limpando os campos BRJ com os dados do Titulo gerado  					 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BRJ->(RecLock("BRJ",.F.))
						
		If BRJ->BRJ_TPCOB == "3"
			If BRJ->BRJ_NIV550 $ '3,5'
				If BRJ->BRJ_ARQPAR == "2"
					BRJ->BRJ_FP2PRE := " " //cPrefixo
					BRJ->BRJ_FP2TIT := " " //cNumero
					BRJ->BRJ_FP2PAR := " " //cParcela
					BRJ->BRJ_FP2TIP := " " //cTipo   
					BRJ->BRJ_NP2PRE := " " //cPrefixo
					BRJ->BRJ_NP2TIT := " " //cNumero
					BRJ->BRJ_NP2PAR := " " //cParcela
					BRJ->BRJ_NP2TIP := " " //cTipo   
				Else
					BRJ->BRJ_PRENDC := " " //cPrefixo NDC
					BRJ->BRJ_NUMNDC := " " //cNumero  NDC
					BRJ->BRJ_PARNDC := " " //cParcela NDC
					BRJ->BRJ_TIPNDC := " " //cTipo    NDC        
					BRJ->BRJ_PREFIX := " " //cPrefixo
					BRJ->BRJ_NUMTIT := " " //cNumero
					BRJ->BRJ_PARCEL := " " //cParcela
					BRJ->BRJ_TIPTIT := " " //cTipo 
				EndIf	
			ElseIf BRJ->BRJ_NIV550 == '7'
				BRJ->BRJ_CNDPRE := " "
				BRJ->BRJ_CNDTIT := " "
				BRJ->BRJ_CNDPAR := " "
				BRJ->BRJ_CNDTIP := " "
				BRJ->BRJ_CFTPRE := " "
				BRJ->BRJ_CFTTIT := " "
				BRJ->BRJ_CFTPAR := " "
				BRJ->BRJ_CFTTIP := " "
			EndIf 
				
		ElseIf BRJ->BRJ_TPCOB == "2"
			If BRJ->BRJ_NIV550 $ '3,5'
				If BRJ->BRJ_ARQPAR == "2"
					BRJ->BRJ_FP2PRE := " " //cPrefixo
					BRJ->BRJ_FP2TIT := " " //cNumero
					BRJ->BRJ_FP2PAR := " " //cParcela
					BRJ->BRJ_FP2TIP := " " //cTipo   
				Else
					BRJ->BRJ_PREFIX := " " //cPrefixo
					BRJ->BRJ_NUMTIT := " " //cNumero
					BRJ->BRJ_PARCEL := " " //cParcela
					BRJ->BRJ_TIPTIT := " " //cTipo   
				EndIf	
			ElseIf BRJ->BRJ_NIV550 == '7'
				BRJ->BRJ_CFTPRE := " " //cPrefixo
				BRJ->BRJ_CFTTIT := " " //cNumero
				BRJ->BRJ_CFTPAR := " " //cParcela
				BRJ->BRJ_CFTTIP := " " //cTipo 
			EndIF
			
		ElseIf BRJ->BRJ_TPCOB == "1"
			If BRJ->BRJ_NIV550 $ '3,5'
				If BRJ->BRJ_ARQPAR == "2"
					BRJ->BRJ_NP2PRE := " " //cPrefixo
					BRJ->BRJ_NP2TIT := " " //cNumero
					BRJ->BRJ_NP2PAR := " " //cParcela
					BRJ->BRJ_NP2TIP := " " //cTipo   
				Else	
					BRJ->BRJ_PRENDC := " " //cPrefixo NDC
					BRJ->BRJ_NUMNDC := " " //cNumero  NDC
					BRJ->BRJ_PARNDC := " " //cParcela NDC
					BRJ->BRJ_TIPNDC := " " //cTipo    NDC
				EndIf	 				
			ElseIf BRJ->BRJ_NIV550 == '7'
				BRJ->BRJ_CNDPRE := " " //cPrefixo
				BRJ->BRJ_CNDTIT := " " //cNumero
				BRJ->BRJ_CNDPAR := " " //cParcela
				BRJ->BRJ_CNDTIP := " " //cTipo 
			EndIF
		Endif
			        
		BRJ->(MsUnLock())            
	Else         
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tratamento do Titulo gerado na versЦo ANTERIOR a 4.1B, foi mantido 		 Ё
		//Ё as condicoes abaixo para manter o legado, caso o cliente deseja cancelar Ё
		//Ё uma exportacao do A560 anterior a versao 4.1B.							 Ё
		//Ё 																		 Ё
		//Ё ATENCAO: Ao realizar o cancelamento sera excluido o AB- Titulo Original. Ё
		//Ё	Para o novo PTU nao sera mais gerado AB-,cliente estara ciente disso.	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		SE1->( DbSetOrder(1) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Cancelamento - Titulo de abatimento fatura								 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BRJ->BRJ_TPCOB == '2'

			If BRJ->BRJ_NIV550 $ '3,5'
				cChvSE1 := Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+"AB-"))
			ElseIf BRJ->BRJ_NIV550 == '7'
				cChvSE1 := Alltrim(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+"AB-"))
			EndIf

			If SE1->( DbSeek(xFilial("SE1")+cChvSE1+"AB-"))
	
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
	        		     	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			             	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
	        		     	{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
				          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
	
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao
				lCan := .T.
			EndIf
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Cancelamento - Titulo de abatimento NDC									 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BRJ->BRJ_TPCOB == '1'

			If BRJ->BRJ_NIV550 $ '3,5'
				cChvSE1 := Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+"AB-"))
			ElseIf BRJ->BRJ_NIV550 == '7'
				cChvSE1 := Alltrim(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+"AB-"))
			EndIf

			If SE1->( DbSeek(xFilial("SE1")+cChvSE1))
	
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
	        		     	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			             	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
	        		     	{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
				          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
	
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao   
				lCan := .T.
			EndIf	
		EndIf
		
		If BRJ->BRJ_TPCOB == '3'

			If BRJ->BRJ_NIV550 $ '3,5'
				cChvSE11 := Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+"AB-"))
				cChvSE12 := Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+"AB-"))
			ElseIf BRJ->BRJ_NIV550 == '7'
				cChvSE13 := Alltrim(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+"AB-"))
				cChvSE14 := Alltrim(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+"AB-"))
			EndIf

			If !Empty(cChvSE11) .And. SE1->( DbSeek(xFilial("SE1")+cChvSE11))
	
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
	        		     	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			             	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
	        		     	{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
				          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
	
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao   
				lCan := .T.
			EndIf

			If !Empty(cChvSE12) .And. SE1->( DbSeek(xFilial("SE1")+cChvSE12))
	
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
	        		     	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			             	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
	        		     	{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
				          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
	
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao   
				lCan := .T.
			EndIf

			If !Empty(cChvSE13) .And. SE1->( DbSeek(xFilial("SE1")+cChvSE13))
	
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
	        		     	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			             	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
	        		     	{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
				          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
	
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao   
				lCan := .T.
			EndIf

			If !Empty(cChvSE14) .And. SE1->( DbSeek(xFilial("SE1")+cChvSE14))
	
				aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
	        		     	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			             	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
	        		     	{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
				          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}
	
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao   
				lCan := .T.
			EndIf
	
		EndIf		
		
		nSeqImp := BRJ->BRJ_CODIGO

        cUpdBD6 := "UPDATE " + RetSqlName("BD6") + " SET"
		
		If BRJ->BRJ_TPCOB == "1"
			cUpdBD6 += " BD6_NDCPRE = ' ',"
			cUpdBD6 += " BD6_NDCTIT = ' ',"
			cUpdBD6 += " BD6_NDCPAR = ' ',"
			cUpdBD6 += " BD6_NDCTIP = ' '"
		ElseIf BRJ->BRJ_TPCOB == "2"
			cUpdBD6 += " BD6_CONPRE = ' ',"
			cUpdBD6 += " BD6_CONTIT = ' ',"
			cUpdBD6 += " BD6_CONPAR = ' ',"
			cUpdBD6 += " BD6_CONTIP = ' '"
		ElseIf BRJ->BRJ_TPCOB == "3"
			cUpdBD6 += " BD6_NDCPRE = ' ',"
			cUpdBD6 += " BD6_NDCTIT = ' ',"
			cUpdBD6 += " BD6_NDCPAR = ' ',"
			cUpdBD6 += " BD6_NDCTIP = ' ',"
			cUpdBD6 += " BD6_CONPRE = ' ',"
			cUpdBD6 += " BD6_CONTIT = ' ',"
			cUpdBD6 += " BD6_CONPAR = ' ',"
			cUpdBD6 += " BD6_CONTIP = ' '"
		EndIf
		
		cUpdBD6 += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND BD6_SEQIMP = '" + nSeqImp + "' AND BD6_CODOPE = '" + cOpePad +"' AND BD6_GUIORI <> ' ' AND "

		If BRJ->BRJ_TPCOB == "1"
			If BRJ->BRJ_NIV550 == '3,5'
				cUpdBD6 += " BD6_NDCPRE = '" + BRJ->BRJ_PRENDC + "' AND "
				cUpdBD6 += " BD6_NDCTIT = '" + BRJ->BRJ_NUMNDC + "' AND "
				cUpdBD6 += " BD6_NDCPAR = '" + BRJ->BRJ_PARNDC + "' AND "
				cUpdBD6 += " BD6_NDCTIP = '" + BRJ->BRJ_TIPNDC + "' AND " 
			ElseIf BRJ->BRJ_NIV550 == '7'
				cUpdBD6 += " BD6_NDCPRE = '" + BRJ->BRJ_CNDPRE + "' AND "
				cUpdBD6 += " BD6_NDCTIT = '" + BRJ->BRJ_CNDTIT + "' AND "
				cUpdBD6 += " BD6_NDCPAR = '" + BRJ->BRJ_CNDPAR + "' AND "
				cUpdBD6 += " BD6_NDCTIP = '" + BRJ->BRJ_CNDTIP + "' AND " 
			EndIf
		ElseIf BRJ->BRJ_TPCOB == "2"
			If BRJ->BRJ_NIV550 $ '3,5'
				cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_PREFIX + "' AND "
				cUpdBD6 += " BD6_CONTIT = '" + BRJ->BRJ_NUMTIT + "' AND "
				cUpdBD6 += " BD6_CONPAR = '" + BRJ->BRJ_PARCEL + "' AND "
				cUpdBD6 += " BD6_CONTIP = '" + BRJ->BRJ_TIPTIT + "' AND " 


			ElseIf BRJ->BRJ_NIV550 == '7'
				cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_CFTPRE + "' AND "
				cUpdBD6 += " BD6_CONTIT = '" + BRJ->BRJ_CFTTIT + "' AND "
				cUpdBD6 += " BD6_CONPAR = '" + BRJ->BRJ_CFTPAR + "' AND "
				cUpdBD6 += " BD6_CONTIP = '" + BRJ->BRJ_CFTTIP + "' AND " 

        	EndIf
		ElseIf BRJ->BRJ_TPCOB == "3"
			If BRJ->BRJ_NIV550 $ '3,5'
				If !Empty(BRJ->BRJ_NUMTIT)
					cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_PREFIX + "' AND BD6_CONTIT = '" + BRJ->BRJ_NUMTIT + "' AND BD6_CONPAR = '" + BRJ->BRJ_PARCEL + "' AND BD6_CONTIP = '" + BRJ->BRJ_TIPTIT + "' AND "
				EndIf
				If !Empty(BRJ->BRJ_NUMNDC)
					cUpdBD6 += " BD6_NDCPRE = '" + BRJ->BRJ_PRENDC + "' AND BD6_NDCTIT = '" + BRJ->BRJ_NUMNDC + "' AND BD6_NDCPAR = '" + BRJ->BRJ_PARNDC + "' AND BD6_NDCTIP = '" + BRJ->BRJ_TIPNDC + "' AND "
				EndIf
			ElseIf BRJ->BRJ_NIV550 == '7'
				If !Empty(BRJ->BRJ_CFTTIT)
					cUpdBD6 += " BD6_CONPRE = '" + BRJ->BRJ_CFTPRE + "' AND BD6_CONTIT = '" + BRJ->BRJ_CFTTIT + "' AND BD6_CONPAR = '" + BRJ->BRJ_CFTPAR + "' AND BD6_CONTIP = '" + BRJ->BRJ_CFTTIP + "' AND "
				EndIf
				If !Empty(BRJ->BRJ_CNDTIT)
					cUpdBD6 += " BD6_NDCPRE = '" + BRJ->BRJ_CNDPRE + "' AND BD6_NDCTIT = '" + BRJ->BRJ_CNDTIT + "' AND BD6_NDCPAR = '" + BRJ->BRJ_CNDPAR + "' AND BD6_NDCTIP = '" + BRJ->BRJ_CNDTIP + "' AND "
				EndIf
			EndIf
		EndIf
		
		cUpdBD6 += "D_E_L_E_T_ = ' '" 
		TCSQLEXEC(cUpdBD6)

		If SubStr(cBanco,1,6) == "ORACLE"
			TCSQLEXEC("COMMIT")
		EndIf
		
	EndIf

	If lCan 	
		MsgInfo(STR0009,STR0024)//"Concluido o processo de CANCELAMENTO!"
	Else
		MsgInfo(STR0010,STR0024)//"NЦo hА tМtulo de compensaГЦo gerado"
	Endif
	
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PL560bto   Ё Autor Ё Nayland             Ё Data Ё 02.12.11 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Gera o arquivo PTU 560 A PARTIR DO BTO                     Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PL560BTO(lReemb)
LOCAL cPLSFiltro := ""
PRIVATE cCadastro := STR0004 //"Ajius ExportaГЦo"
PRIVATE aRotina   := {  { STR0005, 'AxPesqui'		, 0, K_Pesquisar  },; //"Pesquisar"
						{ STR0006, 'PLSUA560VS'		, 0, K_Visualizar },; //"Visualizar"
						{ STR0007, 'PL560GEEXEC(0)'	, 0, K_Incluir    },; //"Exportar"
						{ STR0008, 'PL560GEEXEC(1)'	, 0, K_Excluir    } } //"Cancelar"
PRIVATE cMarcaBto := GetMark()
DEFAULT lReemb := .F.      

cPLSFiltro := "@BTO_FILIAL = '"+xFilial("BTO")+"' "
cPLSFiltro += " AND D_E_L_E_T_ = ' '"
If lReemb
	cPLSFiltro += " AND BTO_REEANE = '1' "
Else
	cPLSFiltro += " AND BTO_REEANE <> '1' "
Endif	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Browse																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("BTO")
SET FILTER TO &cPLSFiltro
BTO->(MarkBrow("BTO","BTO_OK",nil,nil,,cMarcaBto,nil,,,,"PLSUA560MR(2)"))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona a area														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("BTO")
SET FILTER TO
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina														     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PL560GEBTO Ё Autor Ё Nayland             Ё Data Ё 02.12.11 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Gera os arquivos de exportacao/cancela do ajius 			  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PL560GEEXEC(nTp)
LOCAL aRet
LOCAL nFor
LOCAL lSeg		:= .T.
LOCAL lCan		:= .F.
LOCAL lRet		:= .T.
LOCAL aOK		:= {}
LOCAL cPerg		:= "PLU560    "
LOCAL aExclui   := {}
LOCAL aAreaBTO  := {}   
LOCAL aArea     := BTO->(GetArea())
Local cChaveBTO := ""
Local aNumTit   := {}
Local aNumNdc   := {}
Local cBanco     := Alltrim(Upper(TCGetDb()))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pergunte somente se nao for cancelar									 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nTp == 0
	lRet := Pergunte(cPerg,.T.)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processamento															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lRet
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё BTO																		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BTO->( DbSetOrder(1) ) //BRJ_FILIAL + BRJ_CODIGO
		BTO->( DbGoTop() )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё While TBTO																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cQryBTO := ChangeQuery("SELECT * FROM " + RetSqlName("BTO") + " WHERE BTO_FILIAL = '" + xFilial("BTO") + "' AND BTO_OK = '" +cMarcaBto+ "' AND D_E_L_E_T_ = ' '")
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryBTO),"TBTO",.F.,.T.)
		
		Do While !TBTO->( Eof() )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Cancelamento															 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If nTp == 1
					If B2A->( MsSeek( xFilial("B2A")+BRJ->(BRJ_OPEORI+BRJ_NUMFAT) ) )
						If !B2A->B2A_TPARQ $ "2,3"
							While !B2A->( Eof() ) .And. B2A->(B2A_FILIAL+B2A_OPEDES+B2A_NUMTIT) == xFilial("B2A")+BRJ->(BRJ_OPEORI+BRJ_NUMFAT)
								B2A->( RecLock("B2A", .F.) )
								B2A->( dbDelete() )
								B2A->( MsUnlock() )
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Skip																	 Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								B2A->( DbSkip() )
								lCan := .T.
							EndDo
						Else
							MsgStop(STR0017+BRJ->BRJ_NUMFAT+STR0018)//"Existe importaГЦo para a fatura ( "+######+" ), primeiro cancele a importaГЦo!"
						EndIf
					Else
						MsgStop(STR0015+BRJ->BRJ_NUMFAT+STR0016)//"Fatura ( "+#######+" ), ainda nao foi exportada!"
					EndIf
				Else
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Processamento															 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If lSeg
						DbSelectArea("BTO")
						BTO->(DbGoTo(TBTO->R_E_C_N_O_))
						aRet := PL560EXECT()
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Retorno																	 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If Len(aRet) > 0
							If aRet[1]   
								BA0->(DbSetOrder(1))
								BA0->(DbSeek(xFilial("BA0")+BTO->BTO_OPEORI))
								AaDd(aOK,{BA0->(BA0_CODINT+"-"+BA0_NOMINT),"Exportado",aRet[2]}) //"Arquivo Gerado"
							Else
								If Len(aRet[2]) > 0
									AaDd(aOK,{BA0->(BA0_CODINT+"-"+BA0_NOMINT),STR0007,""}) //"Nao foi possivel gerar. Motivo:"
									For nFor := 1 To Len(aRet[2])
										AaDd(aOK,{"",aRet[2,nFor,1]+"-"+aRet[2,nFor,2] ,""})
									Next
								EndIf
							Endif
						EndIf
					EndIf
				EndIf
			TBTO->( DbSkip() )
		Enddo
		TBTO->( dbCloseArea() )
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Len Matriz																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Len(aOK) > 0
		PLSCRIGEN(aOK,{ {"Operadora Destino","@C",150},{STR0012,"@C",250},{STR0013,"@C",060} }, STR0014) //"Operadora Origem"###"Status"###"Arquivo Gerado"###"  Resumo "
	Endif

Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cancelamento															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BTO->( DbSetOrder(1) ) //BRJ_FILIAL + BRJ_CODIGO
	BTO->( DbGoTop() )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё While TBTO																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQryBTO := ChangeQuery("SELECT * FROM " + RetSqlName("BTO") + " WHERE BTO_FILIAL = '" + xFilial("BTO") + "' AND BTO_OK = '" +cMarcaBto+ "' AND D_E_L_E_T_ = ' '")
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryBTO),"TBTO",.F.,.T.)
		
	Do While !TBTO->( Eof() )      
		DbSelectArea("BTO")
		BTO->(DbGoTo(TBTO->R_E_C_N_O_))  
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Quando o Faturamento e para Ambos, vao existir dos BTOs           		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aAreaBTO := BTO->(GetArea())
		BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
		cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
		If BTO->(DbSeek(cChaveBTO)) 
			While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
  
				If BTO->BTO_TPCOB == "1" //NDC-Servicos -> DOC2
					If BTO->BTO_NIV550 $ "3/4/5/6"  
						If BTO->BTO_NIV550 $ "3/4" .And. BTO->BTO_ARQPAR == "2" 
					    	aNumNdc :=  {BTO->BTO_GP2PRE,BTO->BTO_GP2TIT,BTO->BTO_GP2PAR,BTO->BTO_GP2TIP}  
					    Else
					    	aNumNdc :=  {BTO->BTO_GPFPRE,BTO->BTO_GPFTIT,BTO->BTO_GPFPAR,BTO->BTO_GPFTIP} 
					    EndIf
		   			ElseIf BTO->BTO_NIV550 $ "7/8" 
						aNumNdc :=  {BTO->BTO_GCOPRE,BTO->BTO_GCOTIT,BTO->BTO_GCOPAR,BTO->BTO_GCOTIP} 
		   			EndIf 	
				    
				    
				ElseIf BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
				   	If BTO->BTO_NIV550 $ "3/4/5/6"
			  			If BTO->BTO_NIV550 $ "3/4" .And. BTO->BTO_ARQPAR == "2" 
					    	aNumTit :=  {BTO->BTO_GP2PRE,BTO->BTO_GP2TIT,BTO->BTO_GP2PAR,BTO->BTO_GP2TIP}  
					    Else
					    	aNumTit :=  {BTO->BTO_GPFPRE,BTO->BTO_GPFTIT,BTO->BTO_GPFPAR,BTO->BTO_GPFTIP} 
					    EndIf
		   			ElseIf BTO->BTO_NIV550 $ "7/8" 
			   			aNumTit :=  {BTO->BTO_GCOPRE,BTO->BTO_GCOTIT,BTO->BTO_GCOPAR,BTO->BTO_GCOTIP} 
		   			EndIf 
				EndIf   
	
				BTO->(DbSkip())
			EndDo
		EndIf	
	    RestArea(aAreaBTO)

		If BTO->BTO_TPMOV <> '3'
			If BTO->BTO_NIV550 $ "3/4/5/6"  
				If BTO->BTO_NIV550 $ '3/4' .And.  BTO->BTO_ARQPAR == "2" 
	            	Aadd(aExclui,{BTO->BTO_GP2PRE,BTO->BTO_GP2TIT,BTO->BTO_GP2PAR,BTO->BTO_GP2TIP}) 
	        		BTO->( RecLock("BTO", .F.) )
	        		BTO->BTO_GP2PRE := ""
	        		BTO->BTO_GP2TIT := "" 
	        		BTO->BTO_GP2PAR := ""
	        		BTO->BTO_GP2TIP := ""
	        		BTO->(MsUnlock())
	        	Else
	        		Aadd(aExclui,{BTO->BTO_GPFPRE,BTO->BTO_GPFTIT,BTO->BTO_GPFPAR,BTO->BTO_GPFTIP}) 
	        		BTO->( RecLock("BTO", .F.) )
	        		BTO->BTO_GPFPRE := ""
	        		BTO->BTO_GPFTIT := "" 
	        		BTO->BTO_GPFPAR := ""
	        		BTO->BTO_GPFTIP := ""
	        		BTO->(MsUnlock())
	        	EndIf	
        	ElseIf BTO->BTO_NIV550 $ "7/8" 
        	    Aadd(aExclui,{BTO->BTO_GCOPRE,BTO->BTO_GCOTIT,BTO->BTO_GCOPAR,BTO->BTO_GCOTIP})  
        	    BTO->( RecLock("BTO", .F.) )
        		BTO->BTO_GCOPRE := ""
        		BTO->BTO_GCOTIT := "" 
        		BTO->BTO_GCOPAR := ""
        		BTO->BTO_GCOTIP := ""
        		BTO->(MsUnlock())
	        EndIf 
		Else 
		 	aAreaBTO := BTO->(GetArea())
			BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
			cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
			If BTO->(DbSeek(cChaveBTO)) 

               	While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
               		If BTO->BTO_NIV550 $ "3/4/5/6"  
               			If BTO->BTO_NIV550 $ '3/4' .And. BTO->BTO_ARQPAR == "2" 
	               			Aadd(aExclui,{BTO->BTO_GP2PRE,BTO->BTO_GP2TIT,BTO->BTO_GP2PAR,BTO->BTO_GP2TIP})  
	               			BTO->( RecLock("BTO", .F.) )
	        	  			BTO->BTO_GP2PRE := ""
	        	 			BTO->BTO_GP2TIT := "" 
	        	 			BTO->BTO_GP2PAR := ""
	        	  			BTO->BTO_GP2TIP := ""
	        	   			BTO->(MsUnlock())
	               		Else
	               			Aadd(aExclui,{BTO->BTO_GPFPRE,BTO->BTO_GPFTIT,BTO->BTO_GPFPAR,BTO->BTO_GPFTIP})  
	               			BTO->( RecLock("BTO", .F.) )
	        	  			BTO->BTO_GPFPRE := ""
	        	 			BTO->BTO_GPFTIT := "" 
	        	 			BTO->BTO_GPFPAR := ""
	        	  			BTO->BTO_GPFTIP := ""
	        	   			BTO->(MsUnlock())
	        	   		EndIf	
               		ElseIf BTO->BTO_NIV550 $ "7/8" 
               		    Aadd(aExclui,{BTO->BTO_GCOPRE,BTO->BTO_GCOTIT,BTO->BTO_GCOPAR,BTO->BTO_GCOTIP})
               	   	    BTO->( RecLock("BTO", .F.) )
        				BTO->BTO_GCOPRE := ""
		        		BTO->BTO_GCOTIT := "" 
		        		BTO->BTO_GCOPAR := ""
		        		BTO->BTO_GCOTIP := ""
		        		BTO->(MsUnlock())
	                EndIf 
					BTO->(DbSkip())
				EndDo

			EndIf
	       	RestArea(aAreaBTO)	
		EndIf
		
		TBTO->( DbSkip() )
	Enddo
	TBTO->( dbCloseArea() )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё While de exclusao														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
	SE1->( DbSetOrder(1) )
	For nFor := 1 to len (aExclui)
		If SE1->( DbSeek(xFilial("SE1")+aExclui[nFor][1]+aExclui[nFor][2]+aExclui[nFor][3]+aExclui[nFor][4])) .And. ;
				  !(SE1->E1_SALDO == 0 .And. DtoS(SE1->E1_BAIXA) <> ' ' .And. SE1->E1_STATUS == 'B' .And. SE1->E1_VALLIQ == SE1->E1_VALOR)
			aVetor  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
        		     	{"E1_NUM"		,SE1->E1_NUM			,Nil},;
		             	{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
        		     	{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
			          	{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}

			MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao
		EndIf			
	Next
	

	If len(aExclui) > 0	 .And. ( Len(aNumNdc) > 0 .And. !Empty(aNumNdc[2]) ) .Or. ( len(aNumTit) > 0 .And. !Empty(aNumTit[2]) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Vou ajustar o BD6 														 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
		cUpdBD6 := "UPDATE " + RetSqlName("BD6") + " SET"
		
		If BTO->BTO_TPMOV == "1"
			cUpdBD6 += " BD6_NDCPRE = ' ',"
			cUpdBD6 += " BD6_NDCTIT = ' ',"
			cUpdBD6 += " BD6_NDCPAR = ' ',"
			cUpdBD6 += " BD6_NDCTIP = ' '"
		ElseIf BTO->BTO_TPMOV == "2"
			cUpdBD6 += " BD6_CONPRE = ' ',"
			cUpdBD6 += " BD6_CONTIT = ' ',"
			cUpdBD6 += " BD6_CONPAR = ' ',"
			cUpdBD6 += " BD6_CONTIP = ' '"
		ElseIf BTO->BTO_TPMOV == "3"
			cUpdBD6 += " BD6_NDCPRE = ' ',"
			cUpdBD6 += " BD6_NDCTIT = ' ',"
			cUpdBD6 += " BD6_NDCPAR = ' ',"
			cUpdBD6 += " BD6_NDCTIP = ' ',"
			cUpdBD6 += " BD6_CONPRE = ' ',"
			cUpdBD6 += " BD6_CONTIT = ' ',"
			cUpdBD6 += " BD6_CONPAR = ' ',"
			cUpdBD6 += " BD6_CONTIP = ' '"
		EndIf
			
		cUpdBD6 += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND BD6_SEQPF = ' ' AND BD6_GUIORI <> ' ' AND "
	
		If BTO->BTO_TPMOV == "1"
	
			cUpdBD6 += " BD6_NDCPRE = '" + aNumNdc[1] + "' AND "
			cUpdBD6 += " BD6_NDCTIT = '" + aNumNdc[2] + "' AND "
			cUpdBD6 += " BD6_NDCPAR = '" + aNumNdc[3] + "' AND "
			cUpdBD6 += " BD6_NDCTIP = '" + aNumNdc[4] + "' AND " 
		
		ElseIf BTO->BTO_TPMOV == "2"
	
			cUpdBD6 += " BD6_CONPRE = '" + aNumTit[1] + "' AND "
			cUpdBD6 += " BD6_CONTIT = '" + aNumTit[2] + "' AND "
			cUpdBD6 += " BD6_CONPAR = '" + aNumTit[3] + "' AND "
			cUpdBD6 += " BD6_CONTIP = '" + aNumTit[4] + "' AND " 

		ElseIf BTO->BTO_TPMOV == "3"
			If Len(aNumNdc) > 0
				cUpdBD6 += " BD6_NDCPRE = '" + aNumNdc[1] + "' AND "
				cUpdBD6 += " BD6_NDCTIT = '" + aNumNdc[2] + "' AND "
				cUpdBD6 += " BD6_NDCPAR = '" + aNumNdc[3] + "' AND "
				cUpdBD6 += " BD6_NDCTIP = '" + aNumNdc[4] + "' AND "
			EndIf 
				
			If Len(aNumTit) > 0
				cUpdBD6 += " BD6_CONPRE = '" + aNumTit[1] + "' AND "
				cUpdBD6 += " BD6_CONTIT = '" + aNumTit[2] + "' AND "
				cUpdBD6 += " BD6_CONPAR = '" + aNumTit[3] + "' AND "
				cUpdBD6 += " BD6_CONTIP = '" + aNumTit[4] + "' AND " 
			EndIf	 
		EndIf
		cUpdBD6 += "D_E_L_E_T_ = ' '" 

		TCSQLEXEC(cUpdBD6)
	
		If SubStr(cBanco,1,6) == "ORACLE"
			TCSQLEXEC("COMMIT")
		EndIf      
		MsgInfo(STR0009,STR0024)//"Concluido o processo de CANCELAMENTO!"
	Else
		MsgInfo(STR0010,STR0024)//"NЦo hА tМtulo de compensaГЦo gerado"
	Endif

Endif  

RestArea(aArea)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PL560ORI   Ё Autor Ё                     Ё Data Ё 01.12.11 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Gera arquivo do 	Ajius									  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PL560ORI()
LOCAL cDado
LOCAL cFileGerado
LOCAL lContinua  	:= .T.
LOCAL nTamMaxLay 	:= 0
LOCAL cDirFile		:= "\PTU\"
LOCAL aRet			:= {}
LOCAL aStru561		:= {}
LOCAL aStru562		:= {}
LOCAL aStru567		:= {}
LOCAL aStru568		:= {}
LOCAL aStru569		:= {}
LOCAL aCriticas		:= {}
LOCAL nFor 			:= 1
LOCAL aReg561		:={}
LOCAL aReg562		:={}
LOCAL aReg567		:={}
LOCAL aReg568		:={}
LOCAL aReg569		:={}
LOCAL nRegDE1561	:=0
LOCAL nRegDE1562	:=0
LOCAL nRegDE1567	:=0
LOCAL nRegDE1568	:=0
LOCAL nRegDE1569	:=0
LOCAL nSeq			:=1
LOCAL cAliasTrb	:= GetNextAlias()
LOCAL nValorTit		:=0
LOCAL aVetor		:={}
LOCAL nI            := 0
LOCAL nCont         := 0        
LOCAL lTemBaixa1 	:= .F. 
LOCAL lTemBaixa2 	:= .F. 
LOCAL TmpBx	:= GetNextAlias()   
LOCAL cPrefNDC := STRTRAN(GetNewPar("MV_PLPFE19",""),'"','')
LOCAL cTipoArq	    := " "          
LOCAL cFile
LOCAL cTipo      
LOCAL lUltCalc := .T.      
//NOVO        
LOCAL cAno := substr(dtos(dDatabase),1,4)
LOCAL cMes := substr(dtos(dDatabase),5,2)
LOCAL nY	:= 0
LOCAL nTit  := 0 
LOCAL nPosTitInt := 1  //Indica numeracao do titulo que esta sendo gerado. (1-Todos os titulos / 2-Titulo 'Fatura' do A500 quando o lote e do tipo 3-Ambos)
LOCAL nID_ORI    := 0     
LOCAL nFor2 	 := 0     
LOCAL lTem1SE1	 := .F.
LOCAL lTem2SE1	 := .F.
Local cBanco     := Alltrim(Upper(TCGetDb()))
Local cChvSE1   := ""                                
Local nDiasVcto := GetNewPar("MV_PLVCTTC", 10)
Local cTipDoc   := ""
Local cLinha568 := ""
Local aAreaSE1  := {} 
Local lGlosInteg:= .F. 
Local cIndArqPar:= ""
Local cTitVerif := ""
Local cNumTit562:= ""
Local cChvSE1Aba:= ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se layout existe...                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cDirFile := AllTrim(mv_par01)
cLayout  := PadR(mv_par02, 6)
bCodLayPLS := cLayout >= "5.0a"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa o diretorio														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If SubStr(cDirFile,Len(cDirFile),1) # "\"
	cDirFile+="\"
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё EDI																		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DE9->( DbSetOrder(1) )
If !DE9->( MsSeek( xFilial("DE9")+cLayout ) )
	AaDd( aCriticas,{"01",STR0052} ) //"Arquivo de layout EDI A550 nao localizado nas parametrizacoes do sistema."
	lContinua := .F.
Endif

SE1->( DbSetOrder(1) )
If TBRJ->BRJ_TPCOB == '2' .Or. TBRJ->BRJ_TPCOB == '3' .Or. Empty(TBRJ->BRJ_TPCOB)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Regra - Verifica se existe o titulo de abatimento para o lote            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If SE1->( DbSeek(xFilial("SE1")+Alltrim(TBRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+"AB-"))))
		AaDd(aCriticas,{"06",STR0028+Alltrim(TBRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+"AB-"))})//"Titulo de compensГЦo jа gerado"
		lContinua := .F.
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Regra - Verifica se existe o titulo a receber contra a operadora...      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !SE1->( DbSeek(xFilial("SE1")+Alltrim(TBRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))))
		AaDd(aCriticas,{"02",STR0014+Alltrim(TBRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))+STR0015}) //"Titulo a Receber ["###"] nao encontrado."
		lContinua := .F.
	Endif   
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Regra - Verifica se existe o titulo a pagar   contra a operadora...      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SE2->( DbSetOrder(1) )
	If !SE2->( MsSeek(xFilial("SE2")+Alltrim(TBRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)) ))
		AaDd(aCriticas,{"03",STR0016+Alltrim(TBRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2))+STR0015}) //"Titulo a Pagar ["###"] nao encontrado."
		lContinua := .F.
	Endif
EndIf

If TBRJ->BRJ_TPCOB == '1' .Or. TBRJ->BRJ_TPCOB == '3'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Regra - Verifica se existe o titulo de abatimento para o lote            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If SE1->( DbSeek(xFilial("SE1")+Alltrim(TBRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+"AB-"))))
		AaDd(aCriticas,{"06",STR0028+Alltrim(TBRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+"AB-"))})//"Titulo de compensГЦo jа gerado"
		lContinua := .F.
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Regra - Verifica se existe o titulo a receber contra a operadora...      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !SE1->( DbSeek(xFilial("SE1")+Alltrim(TBRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))))
		AaDd(aCriticas,{"02",STR0014+Alltrim(TBRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))+STR0015}) //"Titulo a Receber ["###"] nao encontrado."
		lContinua := .F.
	Endif    
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Regra - Verifica se existe o titulo a pagar   contra a operadora...      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SE2->( DbSetOrder(1) )
	If !SE2->( MsSeek(xFilial("SE2")+Alltrim(TBRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARE2N+BRJ_TIPE2N)) ))
		AaDd(aCriticas,{"03",STR0016+Alltrim(TBRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARE2N+BRJ_TIPE2N))+STR0015}) //"Titulo a Pagar ["###"] nao encontrado."
		lContinua := .F.
	Endif
EndIf

If TBRJ->BRJ_TPCOB == '3'
	nCont := 2     
Else
	nCont := 1	   
EndIf

For nI := 1 to nCont

	If nI == 1
		nPosTitInt := 1
	Else
		nPosTitInt := 2 
	EndIf
	
	SE1->(DbGoTop())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no titulo de contestacao correspondente e verifica se esta baixado Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
 	If TBRJ->BRJ_TPCOB == '2' .OR. Empty(TBRJ->BRJ_TPCOB)   
 	
 		If BRJ->BRJ_NIV550 $ '3,5' .And. !Empty(TBRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)) .And. BRJ->BRJ_GERPTU == "0"
 			If !(cLayout >= "A560E" .And. BRJ->BRJ_ARQPAR == "2" .And. Empty(TBRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP)) )
	 			MsgInfo(STR0029 + Iif(BRJ->BRJ_NIV550=='3',STR0022,STR0025) + " jА gerado!",STR0024) //"Arquivo " + "parcial" + "integral"
	 			Return {}
	 		EndIf	
 		EndIf   
 	
 		If BRJ->BRJ_NIV550 == '7' .And. !Empty(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))
 			MsgInfo(STR0030,STR0024)//"Arquivo complementar jА gerado!"
 			Return {}
 		EndIf 
 		
 		If BRJ->BRJ_GERPTU == "1" .And. BRJ->BRJ_NIV550 == '3'
 			MsgInfo(STR0053+CHR(13)+CHR(10)+;//"NЦo И possМvel gerar o arquivo A560 para Fechamento Parcial quando o tМtulo de contestaГЦo jА foi gerado."
 			         STR0054)//"Para gerar o arquivo e o tМtulo de abatimento, importe o Fechamento Complementar."	   
 			Return {}         
 	    EndIf
 	    
 	    If BRJ->BRJ_NIV550 $ "7|8"
			cTitVerif := TBRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP) 	    
 	    ElseIf BRJ->BRJ_ARQPAR == "2"
 	    	cTitVerif := TBRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP)
 	    Else
 	    	cTitVerif := TBRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)
 	    EndIf	  
 	    
		If	SE1->( DbSeek(xFilial("SE1")+(cTitVerif)))//Posiciona no titulo de Fatura  
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Variavel lTemSE1 verifica se o titulo ja foi gerado nao podendo ser gerado outro titulo Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	   
			lTem1SE1 := !(TBRJ->BRJ_NIV550 $ '5|7')//.T.      
			
			If SE1->E1_SALDO == 0 .And. DtoS(SE1->E1_BAIXA) <> ' ' .And. SE1->E1_STATUS == 'B' .And. SE1->E1_VALLIQ == SE1->E1_VALOR .And. !(TBRJ->BRJ_NIV550 $ '5|7')
	       		lTemBaixa1 := .T.
	  	    Else
	       		 lTemBaixa1 := .F.	
	    	EndIf
		EndIf	  
   
	Elseif TBRJ->BRJ_TPCOB == '1' .OR. (TBRJ->BRJ_TPCOB == '3' .And. nI == 1)   

		cChvSE1 := ""   
 	
 		If BRJ->BRJ_NIV550 $ '3,5' 
 			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё No Ptu 7.0 posso te ter duas parciais                                                   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
 			If cLayout >= "A560E" .And. BRJ->BRJ_ARQPAR == "2" 
 		    	cChvSE1 := TBRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+BRJ_NP2TIP)	
 		    Else
 		    	cChvSE1 := TBRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)
 			EndIf  
 			
 			If !Empty(cChvSE1) .And. BRJ->BRJ_GERPTU == "0"
 				MsgInfo(STR0029 + Iif(BRJ->BRJ_NIV550=='3',STR0022,STR0025) + " jА gerado!",STR0024) //"Arquivo " + "parcial" + "integral"
	 			Return {}   
	 		EndIf
 		EndIf   
 	
 		If BRJ->BRJ_NIV550 == '7'
 			cChvSE1 := TBRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP)
 			If !Empty(cChvSE1) .And. BRJ->BRJ_GERPTU == "0"
	 			MsgInfo(STR0030,STR0024)//"Arquivo complementar jА gerado!"
 				Return {}
 			EndIf
 		EndIf
 
		If !Empty(cChvSE1) .And. SE1->( DbSeek(xFilial("SE1")+cChvSE1)) .And. BRJ->BRJ_GERPTU == "0"//Posiciona no titulo de NDC   
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Variavel lTemSE1 verifica se o titulo ja foi gerado nao podendo ser gerado outro titulo Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	   
			lTem1SE1 := .T.	
				   
			If SE1->E1_SALDO == 0 .And. DtoS(SE1->E1_BAIXA) <> ' ' .And. SE1->E1_STATUS == 'B' .And. SE1->E1_VALLIQ == SE1->E1_VALOR
	       		lTemBaixa1 := .T.
	  	    Else
	       		 lTemBaixa1 := .F.	
	    	EndIf   
        EndIf 
        
	ElseIf TBRJ->BRJ_TPCOB == '3' .And. nI == 2    

		cChvSE1 := ""
 	
 		If BRJ->BRJ_NIV550 $ '3,5' 
 			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё No Ptu 7.0 posso te ter duas parciais                                                   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	   
 			If cLayout >= "A560E" .And. BRJ->BRJ_ARQPAR == "2" 
 		    	cChvSE1 := TBRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP)	
 		    Else	
 		    	cChvSE1 := TBRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)
 		    EndIf
 		    	
 			If !Empty(cChvSE1) .And. BRJ->BRJ_GERPTU == "0"
 				MsgInfo(STR0029 + Iif(BRJ->BRJ_NIV550=='3',STR0022,STR0025) + " jА gerado!",STR0024) //"Arquivo " + "parcial" + "integral"
	 			Return {}       
 			EndIf
 		EndIf   
 	
 		If BRJ->BRJ_NIV550 == '7'
 			cChvSE1 := TBRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP)
 			If !Empty(cChvSE1) .And. BRJ->BRJ_GERPTU == "0"
	 			MsgInfo(STR0030,STR0024)//"Arquivo complementar jА gerado!"
 				Return {}
 			EndIf
 		EndIf
 		
		If !Empty(cChvSE1) .And. SE1->( DbSeek(xFilial("SE1")+cChvSE1)) .And. BRJ->BRJ_GERPTU == "0"//Posiciona no titulo de Fatura  
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Variavel lTemSE1 verifica se o titulo ja foi gerado nao podendo ser gerado outro titulo Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	   
			lTem2SE1 := .T.		
			
			If SE1->E1_SALDO == 0 .And. DtoS(SE1->E1_BAIXA) <> ' ' .And. SE1->E1_STATUS == 'B' .And. SE1->E1_VALLIQ == SE1->E1_VALOR
	       		lTemBaixa2 := .T.
	  	    Else
	       		 lTemBaixa2 := .F.	
	    	EndIf
		EndIf
			
	EndIf    
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Exibe mensagem se existir titulo baixado e gerado                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nI == 1 .And. (lTemBaixa1 .OR. lTem1SE1)
		MsgInfo(STR0031 + SE1->E1_NUM + IIf(lTemBaixa1,STR0032,IIf(lTem1SE1,STR0033,STR0024)))//"TМtulo " + " consta como Baixado no Financeiro" + " jА gerado. Verifique se jА foi exportado o A560" + "Aviso"
	    Return {.F.,{}}
	ElseIf nI == 2 .And. (lTemBaixa2 .OR. lTem2SE1)
		MsgInfo(STR0031 + SE1->E1_NUM + IIf(lTemBaixa1,STR0032,IIf(lTem2SE1,STR0033,STR0024)))//"TМtulo " + " consta como Baixado no Financeiro" + " jА gerado. Verifique se jА foi exportado o A560" + "Aviso"
		Return {.F.,{}}
	Else 
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©            
		//Ё Reembolso                                                                Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If TBRJ->BRJ_TIPLOT == "2"
		 	cTrbBD7 := " SELECT SUM(B7R_VLRGNE) VLRPAG "
			cTrbBD7 += " FROM " + RetSqlName("B7R")
			cTrbBD7 += " WHERE B7R_FILIAL = '"+xFilial("B7R")+"' "
			cTrbBD7 += " AND B7R_CODBRJ = '"+TBRJ->BRJ_CODIGO+"' "    
			cTrbBD7 += " AND B7R_CONTIT = ' ' "
			cTrbBD7 += " AND D_E_L_E_T_ = ' ' " 
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©            
		//Ё BRJ_TPCOB vazio ou tipo '2', utiliza regra antiga                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf Empty(TBRJ->BRJ_TPCOB) .Or. TBRJ->BRJ_TPCOB == '2'
			cTrbBD7 := "SELECT SUM(BD7_VLRGLO + BD7_VLRGTX) VLRPAG "
			cTrbBD7 += "FROM " + RetSqlName("BD6") + " BD6," + RetSqlName("BD7") + " BD7 "
			cTrbBD7 += "WHERE BD7_FILIAL = BD6_FILIAL AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP AND BD7_CODPEG = BD6_CODPEG AND BD7_NUMERO = BD6_NUMERO AND BD7_ORIMOV = BD6_ORIMOV "
			cTrbBD7 += "AND BD7_SEQUEN = BD6_SEQUEN AND BD7_SEQIMP = BD6_SEQIMP "
			cTrbBD7 += "AND BD7_BLOPAG <> '1'  "
			cTrbBD7 += "AND BD6_GUIORI <> ' ' " 
			cTrbBD7 += "AND BD6_CONTIT = ' ' "
			cTrbBD7 += "AND BD6.D_E_L_E_T_ = ' ' AND BD7.D_E_L_E_T_ = ' ' AND BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_SEQIMP = '" + TBRJ->BRJ_CODIGO + "' "
		Else
			cTrbBD7 := "SELECT 	SUM(BD7_VLRGLO) BD7_VLRPAG, SUM(BD7_VLTXPG) BD7_VLTXPG, SUM(BD7_VLADSE) BD7_VLADSE, SUM(BD7_VLRGTX) BD7_VLRGTX "
			cTrbBD7 += "FROM " + RetSqlName("BD6") + " BD6," + RetSqlName("BD7") + " BD7 "
			cTrbBD7 += "WHERE BD7_FILIAL = BD6_FILIAL AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP AND BD7_CODPEG = BD6_CODPEG AND BD7_NUMERO = BD6_NUMERO AND BD7_ORIMOV = BD6_ORIMOV AND BD7_SEQUEN = BD6_SEQUEN AND BD7_SEQIMP = BD6_SEQIMP "
			cTrbBD7 += "AND BD7_BLOPAG <> '1' "
			cTrbBD7 += "AND BD6_GUIORI <> ' ' "
			If TBRJ->BRJ_TPCOB != '3'
				cTrbBD7 += "AND BD6_NDCTIT = ' ' "
			Else
				If nI == 1
					cTrbBD7 += "AND BD6_NDCTIT = ' ' "
				Else
					cTrbBD7 += "AND BD6_CONTIT = ' ' "
				EndIf
			EndIf
			cTrbBD7 += "AND BD6.D_E_L_E_T_ = ' ' AND BD7.D_E_L_E_T_ = ' ' AND BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_SEQIMP = '"+ TBRJ->BRJ_CODIGO +"'"
		EndIf
		
		cTrbBD7 := ChangeQuery(cTrbBD7)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cTrbBD7),"TRBBD7",.F.,.T.)

	EndIf	   		  
	lGlosInteg := .F.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se ha diferenca no valor de glosa entre titulo de contestacao   Ё
	//Ё original e guias importadas pela rotina A550							 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
 	If cGerPtu == "1"  .Or. BRJ->BRJ_GERPTU == "1"   
	
		If TBRJ->BRJ_TPCOB == '1'
			SE1->( DbSeek(xFilial("SE1") + alltrim(TBRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))))//Posiciona no titulo de NDC
			
			nValorTit  := SE1->E1_VALOR - ( TRBBD7->BD7_VLRPAG - TRBBD7->BD7_VLRGTX )
			
			If SE1->E1_VALOR == ( TRBBD7->BD7_VLRPAG - TRBBD7->BD7_VLRGTX )
				lGlosInteg := .T.
			EndIf
			
		ElseIf TBRJ->BRJ_TPCOB == '2' .or. empty(TBRJ->BRJ_TPCOB)
			
			nValorTit  :=  SE1->E1_VALOR - TRBBD7->VLRPAG
			If SE1->E1_VALOR == TRBBD7->VLRPAG 
				lGlosInteg := .T.
			EndIf
			
		ElseIf TBRJ->BRJ_TPCOB == '3' .And. nI == 1
			
			SE1->( DbSeek(xFilial("SE1") + Alltrim(TBRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))))//Posiciona no titulo de NDC
			
			nValorTit  :=  SE1->E1_VALOR - (TRBBD7->BD7_VLRPAG - TRBBD7->BD7_VLRGTX)
			
			If SE1->E1_VALOR == (TRBBD7->BD7_VLRPAG - TRBBD7->BD7_VLRGTX )
				lGlosInteg := .T.
			EndIf
						
		ElseIf TBRJ->BRJ_TPCOB == '3' .And. nI == 2
			
			SE1->( DbSeek(xFilial("SE1")+Alltrim(TBRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))))//Posiciona no titulo de NDC
			
			nValorTit  :=  SE1->E1_VALOR - TRBBD7->BD7_VLRGTX
			
			If SE1->E1_VALOR == TRBBD7->BD7_VLRGTX 
				lGlosInteg := .T.
			EndIf
				
		EndIf
		TRBBD7->(DbCloseArea()) 
		
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁCom o parametro igual a zero nao foi gerado o Titulo Contestacao (SE1),	 Ё
	//Ё	ja estara posicionado na BRJ											 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  	ElseIf cGerPtu == "0" .AND. !lTem1SE1 .OR. (!lTem1SE1 .AND. !lTem2SE1)
	
		If TBRJ->BRJ_TPCOB == '1'
			nValorTit  := (TRBBD7->BD7_VLRPAG - TRBBD7->BD7_VLRGTX)
			
		ElseIf TBRJ->BRJ_TPCOB == '2' .Or. Empty(TBRJ->BRJ_TPCOB)
			nValorTit  :=  TRBBD7->VLRPAG
			
		ElseIf TBRJ->BRJ_TPCOB == '3' .And. nI == 1
			nValorTit  :=  (TRBBD7->BD7_VLRPAG - TRBBD7->BD7_VLRGTX)
			
		ElseIf TBRJ->BRJ_TPCOB == '3' .And. nI == 2
			nValorTit  :=  TRBBD7->BD7_VLRGTX
		EndIf
		TRBBD7->(DbCloseArea()) 

	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё So vai gerar Titulo caso nao tenha titulo gerado na SE1			         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	    
	If !lTem1SE1 .OR. (!lTem1SE1 .AND. !lTem2SE1)
	
		If !(TBRJ->BRJ_NIV550 == "4" .OR. TBRJ->BRJ_NIV550 == "8") 
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё nValorTit refere-se ao valor de Glosa							         Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			If nValorTit > 0	
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se pagamento de lote de intercambio, verifica se gera Fatura e RDC       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cLoteImp 	:= TBRJ->BRJ_CODIGO  // Numero da importacao
				nTit		:= 1	    		// Padrao e gerar um titulo
				cTipTitInt 	:= ""	   			// Padrao e titulo diferente de intercambio
				If !Empty(cLoteImp)
					BRJ->(DbSetOrder(1))
					If BRJ->(DbSeek(xFilial("BRJ")+cLoteImp,.F.))
						Do While !BRJ->(Eof()) .And. BRJ->(BRJ_FILIAL+BRJ_CODIGO) == xFilial("BRJ")+cLoteImp
							If BRJ->BRJ_REGPRI == "1"  //Registro Principal e Status "a Faturar"
								cTipTitInt := BRJ->BRJ_TPCOB
								If Empty(cTipTitInt)
									cTipTitInt := "2"//Se vazio, assume fatura que e o padrao
								EndIf
								If BRJ->BRJ_TPCOB == "3" //Ambos, gero dois titulos
									nTit := 2
								EndIf
								Exit
							EndIf
							BRJ->(DbSkip())
						EndDo
					EndIf
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Busca dados dos parametros...                                            Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BA0->(DbSeek(xFilial("BA0")+BRJ->BRJ_OPEORI))
				SA1->( DbSetOrder(1) )
				SA1->(DbSeek(xFilial("SA1")+BA0->(BA0_CODCLI+BA0_LOJCLI)))
				cPrefNDC := &(GetNewPar("MV_PLPREE1",'"NDC"'))
				cTipoNDC := GetNewPar("MV_PLSTPCP","FT")
				cNumero  := NxtSX5Nota(cPrefNDC,.T.,"1",nil,"BK","PLS")
				lMsErroAuto:=.F.
	            
	            aVetor := {} //Reinicializa vetor
	            If BRJ->BRJ_GERPTU == "1"                 
		            aAdd(aVetor, {"E1_FILIAL" , SE1->E1_FILIAL			, Nil})
					aAdd(aVetor, {"E1_PREFIXO", SE1->E1_PREFIXO			, Nil})
					aAdd(aVetor, {"E1_NUM"    , SE1->E1_NUM				, Nil})
					aAdd(aVetor, {"E1_PARCELA", SE1->E1_PARCELA			, Nil})
					aAdd(aVetor, {"E1_TIPO"   , "AB-"					, Nil})
					aAdd(aVetor, {"E1_VALOR"  , nValorTit				, Nil})
					aAdd(aVetor, {"E1_NATUREZ", SE1->E1_NATUREZ	        , Nil})
					aAdd(aVetor, {"E1_CLIENTE", SE1->E1_CLIENTE			, Nil})
					aAdd(aVetor, {"E1_LOJA"   , SE1->E1_LOJA			, Nil})
					aAdd(aVetor, {"E1_NOMCLI" , SE1->E1_NOMCLI			, Nil})
					aAdd(aVetor, {"E1_EMISSAO", Date()					, Nil})
					aAdd(aVetor, {"E1_VENCTO" , dDataBase+nDiasVcto		, Nil})
					aAdd(aVetor, {"E1_VENCREA", DataValida(dDataBase+nDiasVcto,.T.), Nil})
					aAdd(aVetor, {"E1_HIST"   , "Processo Ajius "		, Nil})
					aAdd(aVetor, {"E1_ORIGEM" , "PLSUA560"				, Nil})
				 	aAdd(aVetor, {"E1_BASEIRF", 0				        , Nil})
					aAdd(aVetor, {"E1_BASEPIS", 0	     				, Nil})
					aAdd(aVetor, {"E1_BASECOF", 0						, Nil})
					aAdd(aVetor, {"E1_BASECSL", 0		        		, Nil})
					aAdd(aVetor, {"E1_BASEINS", 0	            		, Nil})     
					aAdd(aVetor, {"E1_BASEISS", 0		        		, Nil})
					aAdd(aVetor, {"E1_IRRF"	  , 0               		, Nil})
					aAdd(aVetor, {"E1_MULTNAT", "2"             		, Nil})
					aAdd(aVetor, {'E1_DECRESC', 0               		, Nil})
					aAdd(aVetor, {'E1_SDDECRE', 0               		, Nil})
					aAdd(aVetor, {'E1_ACRESC' , 0               		, Nil})
					aAdd(aVetor, {'E1_SDACRES', 0               		, Nil})
					aAdd(aVetor, {'E1_INSS'	  , 0               		, Nil})
					aAdd(aVetor, {'E1_COFINS' , 0               		, Nil})
					aAdd(aVetor, {'E1_PIS'	  , 0               		, Nil})
					aAdd(aVetor, {'E1_IRRF'	  , 0               		, Nil})
					aAdd(aVetor, {'E1_CSLL'	  , 0                		, Nil})
					aAdd(aVetor, {'E1_ISS'    , 0				 		, Nil})
					aAdd(aVetor, {'E1_VRETIRF', 0			            , Nil})
						
			    Else		            
					// Monta array com as informacoes do titulo
					aAdd(aVetor, {"E1_FILIAL" , xFilial("SE1")			, Nil})
	 				aAdd(aVetor, {"E1_PREFIXO", cPrefNDC				, Nil})
					aAdd(aVetor, {"E1_NUM"    , cNumero					, Nil})
					aAdd(aVetor, {"E1_PARCELA", ' '						, Nil})
					aAdd(aVetor, {"E1_TIPO"   , cTipoNDC				, Nil})
					aAdd(aVetor, {"E1_NATUREZ", SA1->A1_NATUREZ			, Nil})     
					aAdd(aVetor, {"E1_CLIENTE", SA1->A1_COD				, Nil})
					aAdd(aVetor, {"E1_LOJA"   , SA1->A1_LOJA			, Nil})
					aAdd(aVetor, {"E1_NOMCLI" , SA1->A1_NOME			, Nil})
					aAdd(aVetor, {"E1_EMISSAO", dDataBase				, Nil})
					aAdd(aVetor, {"E1_VENCTO" , dDataBase+nDiasVcto		, Nil})    
					aAdd(aVetor, {"E1_VENCREA", DataValida(dDataBase+nDiasVcto,.T.), Nil})
					aAdd(aVetor, {"E1_VALOR"  , nValorTit				, Nil})
					aAdd(aVetor, {"E1_HIST"   , "Processo Ajius "		, Nil})
					aAdd(aVetor, {"E1_ORIGEM" , "PLSUA560"				, Nil})
				 	aAdd(aVetor, {"E1_BASEIRF", 0				        , Nil})
					aAdd(aVetor, {"E1_BASEPIS", 0	     				, Nil})
					aAdd(aVetor, {"E1_BASECOF", 0						, Nil})
					aAdd(aVetor, {"E1_BASECSL", 0		        		, Nil})
					aAdd(aVetor, {"E1_BASEINS", 0	            		, Nil})     
					aAdd(aVetor, {"E1_BASEISS", 0		        		, Nil})
					aAdd(aVetor, {"E1_IRRF"	  , 0               		, Nil})
					aAdd(aVetor, {"E1_MULTNAT", "2"             		, Nil})
					aAdd(aVetor, {'E1_DECRESC', 0               		, Nil})
					aAdd(aVetor, {'E1_SDDECRE', 0               		, Nil})
					aAdd(aVetor, {'E1_ACRESC' , 0               		, Nil})
					aAdd(aVetor, {'E1_SDACRES', 0               		, Nil})
					aAdd(aVetor, {'E1_INSS'	  , 0               		, Nil})
					aAdd(aVetor, {'E1_COFINS' , 0               		, Nil})
					aAdd(aVetor, {'E1_PIS'	  , 0               		, Nil})
					aAdd(aVetor, {'E1_IRRF'	  , 0               		, Nil})
					aAdd(aVetor, {'E1_CSLL'	  , 0                		, Nil})
					aAdd(aVetor, {'E1_ISS'    , 0				 		, Nil})
					aAdd(aVetor, {'E1_VRETIRF', 0		            	, Nil})
					
		        EndIf
			
				msExecAuto({|x,y| Fina040(x,y)}, aVetor, 3) //Inclusao
				
				If lMsErroAuto
					MOSTRAERRO()
					SE1->( RollBackSX8() )
					aRetTitOpe := {.F.,"","","",""}
				Else
					lGerSE1 := .T.
					SE1->( ConfirmSx8() )
					aRetTitOpe := {.T.,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO}
					msgInfo(STR0034,STR0024)//"Criado Titulo no Financeiro com Sucesso!"
				Endif							

				lGerSE1 := aRetTitOpe[1]
				
				If 	lGerSE1
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Ao gerar o Titulo sera informado no BRJ o numero do titulo gerado		 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BRJ->(RecLock("BRJ",.F.))
					                                                              
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Tipos de cobranca (3-NDC Cobranca Complementar ou 1-NDC Cobranca Integral) Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If BRJ->BRJ_GERPTU == "0"
						If ((cTipTitInt == '3' .And. nPosTitInt == 1) .Or. cTipTitInt == '1')
							If BRJ->BRJ_NIV550 $ '3,5'
								If cLayout >= "A560E" .And. BRJ->BRJ_ARQPAR == "2"
									BRJ->BRJ_NP2PRE := aRetTitOpe[2] //cPrefixo
									BRJ->BRJ_NP2TIT := aRetTitOpe[3] //cNumero
									BRJ->BRJ_NP2PAR := aRetTitOpe[4] //cParcela
									BRJ->BRJ_NP2TIP := aRetTitOpe[5] //cTipo	
								Else
									BRJ->BRJ_PRENDC := aRetTitOpe[2] //cPrefixo
									BRJ->BRJ_NUMNDC := aRetTitOpe[3] //cNumero
									BRJ->BRJ_PARNDC := aRetTitOpe[4] //cParcela
									BRJ->BRJ_TIPNDC := aRetTitOpe[5] //cTipo   
								EndIf	   
								                    
							ElseIf BRJ->BRJ_NIV550 == '7'
								BRJ->BRJ_CNDPRE := aRetTitOpe[2] //cPrefixo
								BRJ->BRJ_CNDTIT := aRetTitOpe[3] //cNumero
								BRJ->BRJ_CNDPAR := aRetTitOpe[4] //cParcela
								BRJ->BRJ_CNDTIP := aRetTitOpe[5] //cTipo
							EndIf
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Tipos de cobranca (3-NDC Cobranca Complementar ou 2- NDC Cobranca Parcial) Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды					
						ElseIf ((cTipTitInt == '3' .And. nPosTitInt == 2) .Or. cTipTitInt == '2')
							If BRJ->BRJ_NIV550 $ '3,5'
								If cLayout >= "A560E" .And. BRJ->BRJ_ARQPAR == "2"
									BRJ->BRJ_FP2PRE := aRetTitOpe[2] //cPrefixo
									BRJ->BRJ_FP2TIT := aRetTitOpe[3] //cNumero
									BRJ->BRJ_FP2PAR := aRetTitOpe[4] //cParcela
									BRJ->BRJ_FP2TIP := aRetTitOpe[5] //cTipo	
								Else
									BRJ->BRJ_PREFIX := aRetTitOpe[2] //cPrefixo
									BRJ->BRJ_NUMTIT := aRetTitOpe[3] //cNumero
									BRJ->BRJ_PARCEL := aRetTitOpe[4] //cParcela
									BRJ->BRJ_TIPTIT := aRetTitOpe[5] //cTipo
								EndIf	
							ElseIf BRJ->BRJ_NIV550 == '7'
								BRJ->BRJ_CFTPRE := aRetTitOpe[2] //cPrefixo
								BRJ->BRJ_CFTTIT := aRetTitOpe[3] //cNumero
								BRJ->BRJ_CFTPAR := aRetTitOpe[4] //cParcela
								BRJ->BRJ_CFTTIP := aRetTitOpe[5] //cTipo
							EndIf
						Endif
					EndIf
					BRJ->(MsUnLock())
   					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Reembolso                												 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If BRJ->BRJ_TIPLOT == "2"  
						B7R->(DbSetOrder(1))//B7R_FILIAL+B7R_CODBRJ+B7R_SEQGUI
						If B7R->(DbSeek(xFilial("B7R")+BRJ->BRJ_CODIGO)) 
							While xFilial("B7R")+BRJ->BRJ_CODIGO == xFilial("B7R")+B7R->B7R_CODBRJ .And. !B7R->(Eof())
								
								If Empty(B7R->B7R_CONTIT) .And. B7R->B7R_VLRGNE <> 0
									B7R->( RecLock("B7R",.F.) )
		   							B7R->B7R_CONPRE := aRetTitOpe[2]
					   				B7R->B7R_CONTIT := aRetTitOpe[3]
					  				B7R->B7R_CONPAR := aRetTitOpe[4]
					  				B7R->B7R_CONTIP := aRetTitOpe[5]
						
		 							B7R->( MsUnLock() )   
								EndIf
								B7R->(DbSkip())
							EndDo
						EndIf
		
					Else
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Posicionando na BRJ para buscar o codigo da PEG e posicionar na BD6		 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BRJ->(dbSetOrder(1))
						BRJ->(DbGoto(BRJ->(RECNO())+1))      // realizado dessa maneira pq o DbSkip nao estava resolvendo    
						nSeqImp := BRJ->BRJ_CODIGO
						BRJ->(DbGoto(BRJ->(RECNO())-1))
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Ao gerar o Titulo sera informado no BD6 o numero do titulo gerado		 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды					
						cQryUpd := "UPDATE " + RetSqlName("BD6") + " SET"
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Titulo de contestacao gerado no final do processo                          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
						If BRJ->BRJ_GERPTU == "0" 
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Tipos de cobranca (3-NDC Cobranca Complementar ou 1-NDC Cobranca Integral) Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
							If ((cTipTitInt == '3' .And. nPosTitInt == 1) .Or. cTipTitInt == '1')
		
								cQryUpd += " BD6_NDCPRE = '" +aRetTitOpe[2]+ "',"//cPrefixo
								cQryUpd += " BD6_NDCTIT = '" +aRetTitOpe[3]+ "',"//cNumero
								cQryUpd += " BD6_NDCPAR = '" +aRetTitOpe[4]+ "',"//cParcela
								cQryUpd += " BD6_NDCTIP = '" +aRetTitOpe[5]+ "' "//cTipo
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Tipos de cobranca (3-NDC Cobranca Complementar ou 2- NDC Cobranca Parcial) Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							ElseIf ((cTipTitInt == '3' .And. nPosTitInt == 2) .Or. cTipTitInt == '2')
							
								cQryUpd += " BD6_CONPRE = '" +aRetTitOpe[2]+ "', "//cPrefixo
								cQryUpd += " BD6_CONTIT = '" +aRetTitOpe[3]+ "', "//cNumero
								cQryUpd += " BD6_CONPAR = '" +aRetTitOpe[4]+ "', "//cParcela
								cQryUpd += " BD6_CONTIP = '" +aRetTitOpe[5]+ "'  "//cTipo
							
							EndIf
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Titulo de contestacao gerado no lote de pagamento                          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
						Else 
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Antigo NDC                                                                 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
							If cTipTitInt == '1'
								cQryUpd += " BD6_NDCPRE = '" +BRJ->BRJ_PRENDC+ "',"//cPrefixo
								cQryUpd += " BD6_NDCTIT = '" +BRJ->BRJ_NUMNDC+ "',"//cNumero
								cQryUpd += " BD6_NDCPAR = '" +BRJ->BRJ_PARNDC+ "',"//cParcela
								cQryUpd += " BD6_NDCTIP = '" +BRJ->BRJ_TIPNDC+ "' "//cTipo
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё 2 - Somente um documento                                                   Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							ElseIf cTipTitInt == '2' .Or. Empty(cTipTitInt) 
								cQryUpd += " BD6_CONPRE = '" +BRJ->BRJ_PREFIX+ "', "//cPrefixo
								cQryUpd += " BD6_CONTIT = '" +BRJ->BRJ_NUMTIT+ "', "//cNumero
								cQryUpd += " BD6_CONPAR = '" +BRJ->BRJ_PARCEL+ "', "//cParcela
								cQryUpd += " BD6_CONTIP = '" +BRJ->BRJ_TIPTIT+ "'  "//cTipo
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё 2 - Dois documentos                                                        Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							ElseIf cTipTitInt == '3'
								cQryUpd += " BD6_NDCPRE = '" +BRJ->BRJ_PRENDC+ "',"//cPrefixo
								cQryUpd += " BD6_NDCTIT = '" +BRJ->BRJ_NUMNDC+ "',"//cNumero
								cQryUpd += " BD6_NDCPAR = '" +BRJ->BRJ_PARNDC+ "',"//cParcela
								cQryUpd += " BD6_NDCTIP = '" +BRJ->BRJ_TIPNDC+ "', "//cTipo   
								cQryUpd += " BD6_CONPRE = '" +BRJ->BRJ_PREFIX+ "', "//cPrefixo
								cQryUpd += " BD6_CONTIT = '" +BRJ->BRJ_NUMTIT+ "', "//cNumero
								cQryUpd += " BD6_CONPAR = '" +BRJ->BRJ_PARCEL+ "', "//cParcela
								cQryUpd += " BD6_CONTIP = '" +BRJ->BRJ_TIPTIT+ "'  "//cTipo
							EndIf
						EndIf
						cQryUpd += " WHERE BD6_FILIAL = '" +xFilial("BD6")+"' AND BD6_SEQIMP = '" +nSeqImp+ "' AND BD6_GUIORI <> ' ' AND "
	
						If BRJ->BRJ_TPCOB == '1'
							cQryUpd += "BD6_NDCTIT = ' ' AND "
						ElseIf BRJ->BRJ_TPCOB == '2'
							cQryUpd += "BD6_CONTIT = ' ' AND "
						ElseIf BRJ->BRJ_TPCOB == '3'
							If nPosTitInt = 1
								cQryUpd += "BD6_NDCTIT = ' ' AND "
							Else
								cQryUpd += "BD6_CONTIT = ' ' AND "
							EndIf
						EndIf
						
						cQryUpd += "D_E_L_E_T_ = ' '"
						
						TCSQLEXEC(cQryUpd)
						If SubStr(cBanco,1,6) == "ORACLE"
							TCSQLEXEC("COMMIT")
						EndIf
					EndIf
				Endif
				
			Else	
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Glosas com mesmo 											 		     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If lGlosInteg .And. BRJ->BRJ_GERPTU == "1" 
					MsgInfo(STR0055)//"A glosa foi acatada integralmente, nЦo serА gerado tМtulo de abatimento."
				ElseIf TBRJ->BRJ_TPCOB != '3' .Or. nI == 2
					MsgInfo(STR0035,STR0024)	//"Arquivo importado nЦo consta valor de Glosa ou nЦo foi importado o arquivo A550"
					Return(aRet)
				EndIf
			EndIf
		Else        //"NЦo И possivel realizar a exportaГЦo, sendo que o Tipo de CobranГa importada " + "foi [" + "] Fechamento " + "Parcial"/"Complementar" + " da Unimed Devedora da NDC" , Atencao
			MsgStop(STR0036 +CHR(13)+CHR(10)+ STR0037 + BRJ->BRJ_NIV550 + STR0038 + IIf(BRJ->BRJ_NIV550 == "4",STR0022,STR0021) + STR0039,STR0040)
			Return(aRet)				
		EndIf
	EndIf
Next

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё checagem de regras... 												     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lContinua .AND. ( (BRJ->BRJ_TPCOB $ '1|2' .and. !(lTemBaixa1)) .OR. (BRJ->BRJ_TPCOB ='3' .and. !(lTemBaixa1 .and. lTemBaixa2)) );
	 .AND. !lTem2SE1 .OR. (!lTem1SE1 .AND. !lTem2SE1)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R561 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R561") )
		AaDd(aCriticas,{"04",STR0017}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0018}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1561 := DE1->( Recno() )
		cChave561  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R562 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R562") )
		AaDd(aCriticas,{"04",STR0012}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0005}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1562 := DE1->( Recno() )
		cChave562  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	          
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R567 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R567") )
		AaDd(aCriticas,{"04",STR0012}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0005}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1567 := DE1->( Recno() )
		cChave567  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif       
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R568 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R568") )
		AaDd(aCriticas,{"04",STR0012}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0005}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1568 := DE1->( Recno() )
		cChave568  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R569 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R569") )
		AaDd(aCriticas,{"04",STR0012}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0005}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1569 := DE1->( Recno() )
		cChave569  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	
	
	nSeq++
	DE1->( DbGoTo(nRegDE1561) )
	
	While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave561
		
		If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"       //001
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(1,DE1->DE1_LAYTAM)})
	   
		ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"  //002
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"562" } )
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UNI_DES" // 003
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,BRJ->BRJ_OPEORI})
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UNI_ORI"   //004
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,PLSINTPAD() } )
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO" .And. cLayout >= "A560D"     //006
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(11)})  
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_FATURA","NR_DOC_1") .And. cLayout < "A560D"      //006
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,PadR(BRJ->BRJ_NUMFAT,11)})
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOT_FAT","VL_TOT_DO1") //007
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BRJ->BRJ_VLRFAT*100,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_VER_TRA" //008
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,&(DE1->DE1_REGRA)})
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO" .And. cLayout >= "A560D" //009
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(11)})  
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_NDC","NR_DOC_2") .And. cLayout < "A560D" //009
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,PadR(BRJ->BRJ_NRNDC,11)})
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOT_NDC","VL_TOT_DO2") //010
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BRJ->BRJ_VLRNDC*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tipo de Arquivo - TP_ARQUIVO 									Ё
		//Ё 	Regra:														Ё
		//Ё 	Quando o PTU A550 importado com o Tipo 5 ou 6:				Ё
		//Ё 		Gera: 1-NDC CobranГa Integral							Ё
		//Ё 	Quando o PTU A550 importado com o Tipo 3 ou 4:				Ё						
		//Ё 		Gera: 2-NDC CobranГa Parcial 							Ё
		//Ё 	Quando o PTU A550 importado com o Tipo 7 ou 8:				Ё			
		//Ё 		Gera: 3-NDC CobranГa Complementar                    	Ё				
		//Ё 																Ё
		//Ё     Obs.: Ao importar o A550 o tipo eh alimentado no BRJ_NIV550 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        cTipoArq := BRJ->BRJ_NIV550
	   	ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_ARQUIVO" //011                                                                          
			If cTipoArq $ '3|4'
				AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"2" })
		    ElseIf cTipoArq $ '7|8'
				AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"3" })		    
			ElseIf cTipoArq $ '5|6'
				AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"1" }) 			    
			EndIf
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_FATURA","NR_DOC_1") .And. cLayout >= "A560D"   //012
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Padr(BRJ->BRJ_NUMFAT,20)})   
	
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_NDC","NR_DOC_2") .And. cLayout >= "A560D"//013
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Padr(BRJ->BRJ_NRNDC,20)})	
			
		ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_ARQ_PAR" .And. cLayout >= "A560E" //014
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,IIf(BRJ->BRJ_NIV550 $ "3|4",BRJ->BRJ_ARQPAR,"0")})
		Endif
			
		DE1->( DbSkip() )
	Enddo
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Registro 562												    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	For nI := 1 to nCont   
	
		AaDd( aReg562,{BD7->( Recno() ),{} } )
		nBottomArray := Len(aReg562)	
		DE1->( DbGoTo(nRegDE1562) )                         	
		nID_ORI++	
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Ajuste para versao 7.0, o titulo da parcial varia 			    		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  	
		If cLayout >= "A560E" .And. BRJ->BRJ_ARQPAR == "2"
		    
		    Do Case 
		    	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё BRJ->BRJ_TPCOB = "1" Nao e mais utilizado       			    		 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  	
		    	Case nI == 1 .AND. BRJ->BRJ_TPCOB == "1"
		    		cNumTit562 := StrZero(Val(BRJ->BRJ_NUMNDC),11)
		    	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё BRJ->BRJ_TPCOB = "2" Gera somente um titulo de contestacao 	    		 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  	
		    	Case nI == 1 .AND. BRJ->BRJ_TPCOB == "2" .And. BRJ->BRJ_NIV550 == "3" 	
		    		If BRJ->BRJ_ARQPAR == "1" 
		    			cNumTit562 := StrZero(Val(BRJ->BRJ_NUMTIT),11)   
		    		ElseIf BRJ->BRJ_ARQPAR == "2" 
		    			cNumTit562 := StrZero(Val(BRJ->BRJ_FP2TIT),11)   
		    		EndIf       
		    		
		    	Case nI == 1 .AND. BRJ->BRJ_TPCOB == "2" .And. BRJ->BRJ_NIV550 == "5" 
		    		cNumTit562 := StrZero(Val(BRJ->BRJ_NUMTIT),11)   
		    	
		    	Case nI == 1 .AND. BRJ->BRJ_TPCOB == "2" .And. BRJ->BRJ_NIV550 == "7" 	 
		    		cNumTit562 := StrZero(Val(BRJ->BRJ_CFTTIT),11)	 
		    	
		    	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё BRJ->BRJ_TPCOB = "3" Gera dois titulos de contestacao: Servicos			 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  		
		    	Case nI == 1 .AND. BRJ->BRJ_TPCOB == "3" .And. BRJ->BRJ_NIV550 == "3" 	
		       		If BRJ->BRJ_ARQPAR == "1" 
		    			cNumTit562 := StrZero(Val(BRJ->BRJ_NUMNDC),11)   
		    		ElseIf BRJ->BRJ_ARQPAR == "2" 
		    			cNumTit562 := StrZero(Val(BRJ->BRJ_NP2TIT),11)   
		    		EndIf     
		    	
		    	Case nI == 1 .AND. BRJ->BRJ_TPCOB == "3" .And. BRJ->BRJ_NIV550 == "5" 		
		    		cNumTit562 := StrZero(Val(BRJ->BRJ_NUMNDC),11)	
		    		
		    	Case nI == 1 .AND. BRJ->BRJ_TPCOB == "3" .And. BRJ->BRJ_NIV550 == "7" 		  					 
		    		cNumTit562 := StrZero(Val(BRJ->BRJ_CNDTIT),11)     
		    		
		    	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё BRJ->BRJ_TPCOB = "3" Gera dois titulos de contestacao: Taxas 			 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
		    	Case nI == 2 .And. BRJ->BRJ_NIV550 == "3"
		    		If BRJ->BRJ_ARQPAR == "1" 
		    			cNumTit562 := StrZero(Val(BRJ->BRJ_NUMTIT),11)   
		    		ElseIf BRJ->BRJ_ARQPAR == "2" 
		    			cNumTit562 := StrZero(Val(BRJ->BRJ_FP2TIT),11)   
		    		EndIf                                 
		    	
		    	Case nI == 2 .And. BRJ->BRJ_NIV550 == "5"	
		    		cNumTit562 := StrZero(Val(BRJ->BRJ_NUMTIT),11)	
		    			
		    	Case nI == 2 .And. BRJ->BRJ_NIV550 == "7"	
		      		cNumTit562 := StrZero(Val(BRJ->BRJ_CFTTIT),11)
		      				      		
		    EndCase

		Else
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Tratamento antigo											    		 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
			If nI == 1 .AND. BRJ->BRJ_TPCOB == "1"
				cNumTit562 := StrZero(Val(BRJ->BRJ_NUMNDC),11)
			
			ElseIf (nI == 1 .AND. BRJ->BRJ_TPCOB == "2") 
				cNumTit562 :=  StrZero(Val(Iif(BRJ->BRJ_NIV550$'3,5',BRJ->BRJ_NUMTIT,BRJ->BRJ_CFTTIT)),11)
				  			
			ElseIf (nI == 1 .AND. BRJ->BRJ_TPCOB == "3") 
		 		cNumTit562 :=  StrZero(Val(Iif(BRJ->BRJ_NIV550$'3,5',BRJ->BRJ_NUMNDC,BRJ->BRJ_CNDTIT)),11)   
		 		  			
			ElseIf nI == 2
			 	cNumTit562 :=  StrZero(Val(Iif(BRJ->BRJ_NIV550$'3,5',BRJ->BRJ_NUMTIT,BRJ->BRJ_CFTTIT)),11)						
			EndIf
		EndIf
		
		While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave562 
		   
			If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"       //001
				AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nSeq++,DE1->DE1_LAYTAM)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"  //002
				AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"562" } )      
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_NOTA_DB" // 003
		
				AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cNumTit562})      
	
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_VEN_NT" //004
				AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,dtos(SE1->E1_VENCTO)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "ID_NDC_CON" //005    
				If BRJ->BRJ_TPCOB == '1'
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"1" } )
				ElseIf BRJ->BRJ_TPCOB == '2'
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"2" } )			
				ElseIf BRJ->BRJ_TPCOB == '3' .And. nI == 1				
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"1" } )						
				ElseIf BRJ->BRJ_TPCOB == '3' .And. nI == 2
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"2" } )
				EndIf									
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Proximo																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DE1->( DbSkip() )
		Enddo   
				
		If !(empTy(aReg562[nBottomArray,2])) .AND. Val(aReg562[nBottomArray,2,3,4]) == 0//na manda registro com valor zero
			aReg562 := {}
		EndIf

		DE1->( DbGoTo(nRegDE1562) )                         
	Next
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Registro 567												    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	For nI := 1 to 2   
	
		AaDd( aReg567,{BD7->( Recno() ),{} } )
		nBottomArray := Len(aReg567)	
		DE1->( DbGoTo(nRegDE1567) )                         	
		nID_ORI++	   
		
		If nI == 1
			BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
			BA0->(DbSeek(xFilial("BA0")+BRJ->BRJ_OPEORI))
		Else
			BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
			BA0->(DbSeek(xFilial("BA0")+PLSINTPAD()))
		EndIf
		
		While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave567 
		   
			If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"          //001 NЗmero seqЭencial de um registro em um arquivo de transferЙncia
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nSeq++,DE1->DE1_LAYTAM)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"      //002 Tipo de registro para os arquivos de troca de informaГУes batch.
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"567" } )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_CRED_DE"  //003 IdentificaГЦo do tipo de registro
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Iif(nI==1,"2","1") } )
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NM_CRED_DE"   //004 Nome completo da Credora ou Devedora
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Padr(BA0->BA0_NOMINT,60)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_ENDEREC"  //005 DescriГЦo do EndereГo
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Padr(BA0->BA0_END,40) } )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_END_CPL"  //006 DescriГЦo complementar do EndereГo
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Padr(BA0->BA0_COMPEN,20)} )   
					
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_END"     //007 NЗmero na via pЗblica.
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,IIf(Empty(BA0->BA0_NUMEND),Padr("S/N",6),padr(BA0->BA0_NUMEND,6))})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_BAIRRO"  //008 DescriГЦo do Bairro  
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,padr(BA0->BA0_BAIRRO,30)} )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_CEP"     //009 NЗmero do CEP
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,padr(BA0->BA0_CEP,8) } )       
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_CIDADE"  //010 DescriГЦo da Cidade
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,padr(BA0->BA0_CIDADE,30)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UF"      //011 CСdigo da Unidade Federativa
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,padr(BA0->BA0_EST,2)} )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_CNPJ_CP" //012 CСdigo do CNPJ ou CPF
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Val(BA0->BA0_CGC),14)} )  
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_DDD"     //013 NЗmero do DDD
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,strzero(val(iif(empty(BA0->BA0_DDD),substr(BA0->BA0_TELEF1,0,2),BA0->BA0_DDD)),4)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_FONE"    //014 NЗmero do Telefone
				cTel := cvaltochar(val(strtran(BA0->BA0_TELEF1,'-','')))
				strtran(BA0->BA0_FAX1  ,'-','')
				if empty(cTel)
					cTel := strzero(0,9)
				elseif empty(BA0->BA0_DDD) //Assumo que o DDD estА nesse campo e removo
					cTel := substr(cTel,3,len(cTel))
				endif

				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,strzero(val(substr(cTel,0,9)),9) } )   	

			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_FAX"     //015 NЗmero do fac-sМmile.
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Iif(!Empty(BA0->BA0_FAX1 ),strzero(Val(strtran(BA0->BA0_FAX1  ,'-','')),9),strzero(0,9))} )   	 	
			EndIf	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Proximo																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DE1->( DbSkip() )
		Enddo   

		DE1->( DbGoTo(nRegDE1567) )                         
	Next    
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Registro 568												    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	For nI := 1 to nCont   
	
		AaDd( aReg568,{BD7->( Recno() ),{} } )
		nBottomArray := Len(aReg568)	
		DE1->( DbGoTo(nRegDE1568) )                         	
		nID_ORI++	   
		
		BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		BA0->(DbSeek(xFilial("BA0")+PLSINTPAD()))    
		SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Parcial / Fechamento 										    		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
		If Val(BRJ->BRJ_NIV550) < 7  
		
			If Empty(BRJ->BRJ_TPCOB) .Or. BRJ->BRJ_TPCOB == '2'  
				If BRJ->BRJ_NIV550 $ "3/4" .And. BRJ->BRJ_ARQPAR == "2" 
			  		SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP))))   
				Else
					SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))))   
				EndIf
				cTipDoc := "2"  
				
	        ElseIf BRJ->BRJ_TPCOB == '3' .And. nI == 1
	       	    If BRJ->BRJ_NIV550 $ "3/4" .And. BRJ->BRJ_ARQPAR == "2" 
	       	        SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+BRJ_NP2TIP)))) 
	       	    Else
	       	    	SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))))
	       	    EndIf
	       	    cTipDoc := "1"
	        
	        ElseIf BRJ->BRJ_TPCOB == '3' .And. nI == 2           
	        	If BRJ->BRJ_NIV550 $ "3/4" .And. BRJ->BRJ_ARQPAR == "2" 
	        		SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP))))
	        	Else
	            	SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))))
	            EndIf
	            cTipDoc := "2"
			
			ElseIf BRJ->BRJ_TPCOB == '1'
				SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)))) 
				cTipDoc := "1"
			EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Complemento       	 										    		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
		Else
			If Empty(BRJ->BRJ_TPCOB) .Or. BRJ->BRJ_TPCOB == '2' 
				SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))))     
				cTipDoc := "2"
	        ElseIf BRJ->BRJ_TPCOB == '3' .And. nI == 1
	       	    SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))))
	       	    cTipDoc := "1"
	        ElseIf BRJ->BRJ_TPCOB == '3' .And. nI == 2
	            SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))))  
	            cTipDoc := "2"
			ElseIf BRJ->BRJ_TPCOB == '1'
				SE1->(DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))))
				cTipDoc := "1"
			EndIf		
		EndIf   
		
		If cTipDoc == "1"
			cLinha568 := Padr(&(GetNewPar("MV_PLL5681", "'Cobranca referente a Contestacao da NDR'")),74)
		Else
			cLinha568 := Padr(&(GetNewPar("MV_PLL5682", "'Cobranca referente a Contestacao da Fatura'")),74) 
		EndIf
		
		While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave568 
		   
			If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"          //001 NЗmero seqЭencial de um registro em um arquivo de transferЙncia.
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nSeq++,DE1->DE1_LAYTAM)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"      //002 Tipo de registro para os arquivos de troca de informaГУes batch.
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"568" } )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_EMI_NDC"  //003 Data de emissЦo da Nota de DИbito
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Dtos(SE1->E1_EMISSAO)} )//1-Credora   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_VEN_NDC"  //004 Data de vencimento da Nota de DИbito
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Dtos(SE1->E1_VENCTO)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_LINHA"    //005 NЗmero da linha do item a ser impresso
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Strzero(nI,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_LINHA"    //006 DescriГЦo da linha da Fatura
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cLinha568 } )   
					
			ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_NDC"      //007 Valor da Nota de DИbito 
				If BRJ->BRJ_GERPTU == "1" 
                	aAreaSE1 := SE1->(GetArea()) 
                	nVlrCont := SE1->E1_VALOR
                	If SE1->(DbSeek(xFilial("SE1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)+"AB-"))    
                		AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero((nVlrCont-SE1->E1_VALOR)*100,DE1->(DE1_LAYTAM+DE1_LAYDEC)) })   
                		RestArea(aAreaSE1)//Se achar titulo de abatimento, restauro a area depois
                	Else
                		RestArea(aAreaSE1)//Se nao achar titulo de abatimento, restauro a area antes
                		AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(SE1->E1_VALOR*100,DE1->(DE1_LAYTAM+DE1_LAYDEC)) })   
                	EndIf
                Else
					AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(SE1->E1_VALOR*100,DE1->(DE1_LAYTAM+DE1_LAYDEC)) })   
				EndIf
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_DOC_568"  //008 Tipo de documento
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cTipDoc} )   
			
			EndIf	   
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Proximo																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DE1->( DbSkip() )
		Enddo   

		DE1->( DbGoTo(nRegDE1568) )                         
	Next 
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Registro 569												    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	AaDd( aReg569,{BD7->( Recno() ),{} } )
	nBottomArray := Len(aReg569)	
	DE1->( DbGoTo(nRegDE1569) )                         	
	nID_ORI++	   
		
	BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	BA0->(DbSeek(xFilial("BA0")+PLSINTPAD()))
		
	While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave569 
   
		If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"       //001
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nSeq++,DE1->DE1_LAYTAM)})   
			
		ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"  //002 Tipo de registro para os arquivos de troca de informaГУes batch.
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"569" } )   
			   
		ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO" .And. cLayout >= "A560D"//003 Reservado
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(11) } )
	   
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_FATURA","NR_DOC_1")  .And. cLayout < "A560D"//003 NЗmero da Fatura √ A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,PadR(BRJ->BRJ_NUMFAT,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )//1-Credora   
						
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"DT_EMI_FAT","DT_EMI_DO1")   //004 Data de emissЦo da Fatura √ A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Dtos(BRJ->BRJ_DTEMIS)})   
				
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOT_FAT","VL_TOT_DO1")  //005 Valor total da fatura √ A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BRJ->BRJ_VALOR*100,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )   
			   
		ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO"  .And. cLayout >= "A560D"//006 Reservado
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(11) } )   
			
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_NDR","NR_DOC_2")  .And. cLayout < "A560D"//006 Nota de DИbito/CrИdito (Reembolso) √ A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,PadR(BRJ->BRJ_NRNDC,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )   
				
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"DT_EMI_NDR","DT_EMI_DO2")  //007 Data de emissЦo da NDR √ A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Dtos(BRJ->BRJ_DTENDC) })   
				
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOT_NDR","VL_TOT_DO2")  //008 Valor total da NDR √ A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BRJ->BRJ_VLRNDC*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))} )   
	   
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_FATURA","NR_DOC_1")  .And. cLayout >= "A560D"//009 NЗmero da Fatura √ A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,PadR(BRJ->BRJ_NUMFAT,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )//1-Credora   
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_NDR","NR_DOC_2") .And. cLayout >= "A560D" //010 Nota de DИbito/CrИdito (Reembolso) √ A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,PadR(BRJ->BRJ_NRNDC,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )   
							
		EndIf	   
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Proximo																	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DE1->( DbSkip() )
	Enddo   
	DE1->( DbGoTo(nRegDE1569) )                         

	
Endif   

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё So vai exportar caso nao tenha titulo gerado na SE1		    	         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	    
If !lTem1SE1 .OR. (!lTem1SE1 .AND. !lTem2SE1)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se tem criticas												 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Len(aCriticas) > 0
		aRet := {.F.,aCriticas}
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se existe 	registro										 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Len(aReg562) > 0
			//здддддддддддддддддддд©
			//Ё TEMPORARIO 561     Ё
			//юдддддддддддддддддддды
			aadd(aStru561,{"CHAVE","C",022,0})
			aadd(aStru561,{"CAMPO" ,"C",113,0})
			
			//--< CriaГЦo do objeto FWTemporaryTable >---
			oTempR61 := FWTemporaryTable():New( "R61" )
			oTempR61:SetFields( aStru561 )
			oTempR61:AddIndex( "INDR61",{ "CHAVE" } )
			
			if( select( "R61" ) > 0 )
				R61->( dbCloseArea() )
			endIf
			
			oTempR61:Create()
			
			//здддддддддддддддддддд©
			//Ё TEMPORARIO 562     Ё
			//юдддддддддддддддддддды
			aadd(aStru562,{"CHAVE","C",022,0})
			aadd(aStru562,{"CAMPO" ,"C",031,0})
			
			//--< CriaГЦo do objeto FWTemporaryTable >---
			oTempR62 := FWTemporaryTable():New( "R62" )
			oTempR62:SetFields( aStru562 )
			oTempR62:AddIndex( "INDR62",{ "CHAVE" } )
			
			if( select( "R62" ) > 0 )
				R62->( dbCloseArea() )
			endIf
			
			oTempR62:Create()

   			dbSelectArea( "R62" )
  			R62->( dbSetorder( 1 ) )    
  			
  			//здддддддддддддддддддд©
			//Ё TEMPORARIO 567     Ё
			//юдддддддддддддддддддды
			aadd(aStru567,{"CHAVE","C",022,0})
			aadd(aStru567,{"CAMPO" ,"C",244,0})
			
			//--< CriaГЦo do objeto FWTemporaryTable >---
			oTempR67 := FWTemporaryTable():New( "R67" )
			oTempR67:SetFields( aStru567 )
			oTempR67:AddIndex( "INDR67",{ "CHAVE" } )
			
			if( select( "R67" ) > 0 )
				R67->( dbCloseArea() )
			endIf
			
			oTempR67:Create()
			
   			dbSelectArea( "R67" )
  			R67->( dbSetorder( 1 ) )   
  			
  			//здддддддддддддддддддд©
			//Ё TEMPORARIO 568     Ё
			//юдддддддддддддддддддды
			aadd(aStru568,{"CHAVE","C",022,0})
			aadd(aStru568,{"CAMPO" ,"C",118,0})
			
			//--< CriaГЦo do objeto FWTemporaryTable >---
			oTempR68 := FWTemporaryTable():New( "R68" )
			oTempR68:SetFields( aStru568 )
			oTempR68:AddIndex( "INDR68",{ "CHAVE" } )
			
			if( select( "R68" ) > 0 )
				R68->( dbCloseArea() )
			endIf
			
			oTempR68:Create()
			
   			DbSelectArea( "R68" )
  			R68->( dbSetorder( 1 ) )
  			
  			//здддддддддддддддддддд©
			//Ё TEMPORARIO 569     Ё
			//юдддддддддддддддддддды
			aadd(aStru569,{"CHAVE","C",022,0})
			aadd(aStru569,{"CAMPO" ,"C",117,0})
			
			//--< CriaГЦo do objeto FWTemporaryTable >---
			oTempR69 := FWTemporaryTable():New( "R69" )
			oTempR69:SetFields( aStru569 )
			oTempR69:AddIndex( "INDR69",{ "CHAVE" } )
			
			if( select( "R69" ) > 0 )
				R69->( dbCloseArea() )
			endIf
			
			oTempR69:Create()
			
   			dbSelectArea( "R69" )
  			R69->( dbSetorder( 1 ) )
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Gera linha registro R561												 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cDado := ""
			For nFor := 1 To Len(aReg561)
				cDado += aReg561[nFor,4]
			Next
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava linha R561 no temporario											 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			R61->( RecLock("R61",.T.) )
			R61->CAMPO := cDado
			R61->( MsUnLock() )           
			                         
	        //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	 		//Ё Gera linha registro R562												 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   		For nFor := 1 To Len(aReg562) 
			cDado := ""
				For nFor2 := 1 to len(aReg562[nFor,2])
					cDado += aReg562[nFor,2,nFor2,4]
				Next nFor2  
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   		//Ё Grava linha R562														 Ё
	   			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
				R62->( RecLock("R62",.T.) )
				R62->CAMPO := cDado
				R62->Chave := StrZero(nFor,19)+"562"
				R62->( MsUnLock() ) 
			Next	     		
			
		    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	 		//Ё Gera linha registro R567												 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   		For nFor := 1 To Len(aReg567) 
			cDado := ""
				For nFor2 := 1 to len(aReg567[nFor,2])
					cDado += aReg567[nFor,2,nFor2,4]
				Next nFor2  
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   		//Ё Grava linha R567														 Ё
	   			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
				R67->( RecLock("R67",.T.) )
				R67->CAMPO := cDado    
				R67->Chave := StrZero(nFor,19)+"567"
				R67->( MsUnLock() ) 
			Next   
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	 		//Ё Gera linha registro R568												 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   		For nFor := 1 To Len(aReg568) 
			cDado := ""
				For nFor2 := 1 to len(aReg568[nFor,2])
					cDado += aReg568[nFor,2,nFor2,4]
				Next nFor2  
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   		//Ё Grava linha R568														 Ё
	   			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
				R68->( RecLock("R68",.T.) )
				R68->CAMPO := cDado    
				R68->Chave := StrZero(nFor,19)+"568"
				R68->( MsUnLock() ) 
			Next 
			
		    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	 		//Ё Gera linha registro R569												 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   		For nFor := 1 To Len(aReg569) 
			cDado := ""
				For nFor2 := 1 to len(aReg569[nFor,2])
					cDado += aReg569[nFor,2,nFor2,4]
				Next nFor2  
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   		//Ё Grava linha R569														 Ё
	   			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
				R69->( RecLock("R69",.T.) )
				R69->CAMPO := cDado    
				R69->Chave := StrZero(nFor,19)+"569"
				R69->( MsUnLock() ) 
			Next	     		
	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inicio do arquivo														 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			R62->( DbGoTop() )
		
			If BRJ->BRJ_TPCOB <> "1" 
				IIf(len(Alltrim(BRJ->BRJ_NUMFAT)) < 7,cFile := Alltrim(BRJ->BRJ_NUMFAT),cFile := SubStr(Alltrim(BRJ->BRJ_NUMFAT),Len(Alltrim(BRJ->BRJ_NUMFAT)) - 6, 7))
			Else  
				IIf(len(Alltrim(BRJ->BRJ_NRNDC)) < 7,cFile := Alltrim(BRJ->BRJ_NRNDC),cFile := SubStr(Alltrim(BRJ->BRJ_NRNDC),Len(Alltrim(BRJ->BRJ_NRNDC)) - 6, 7))
			EndIf  
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Versao 6.0 completa com _ no inicio do nome do arquivo					 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If cLayout >= "A560D" .And. len(cFile) < 7 
				cFile := Replicate("_",7-len(cFile)) + cFile			
			EndIf
			
			If BRJ->BRJ_NIV550 = "3"
				cTipo := "2_"
			ElseIf BRJ->BRJ_NIV550 = "5"
				cTipo := "1_"
			ElseIf BRJ->BRJ_NIV550 = "7"
				cTipo := "3_"
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Versao 7.0 verifica se e um registro parcial         					 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If cLayout >= "A560E" .And. BRJ->BRJ_NIV550 $ "3|4" .And. !Empty(BRJ->BRJ_ARQPAR)   
            	cIndArqPar := "_"+BRJ->BRJ_ARQPAR
			EndIf		
			
			cFileGerado := Upper(cDirFile+"ND"+ cTipo + cFile +cIndArqPar+"."+SubStr(PLSINTPAD(), 2, 3))
			cArqNom		:= Upper("ND"+ cTipo + cFile +cIndArqPar+"."+SubStr(PLSINTPAD(), 2, 3))
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			R62->(DbGoTop())
			R67->(DbGoTop())
			R68->(DbGoTop())
			R69->(DbGoTop())
			If  ! R62->(EOF())
				PTULn("561",.T.)
				PlsPTU(padr(mv_par02,6),cArqNom,cDirFile)
			Endif
			
			if( select( "R61" ) > 0 )
				oTempR61:delete()
			endIf

			if( select( "R62" ) > 0 )
				oTempR62:delete()
			endIf

			if( select( "R67" ) > 0 )
				oTempR67:delete()
			endIf

			if( select( "R68" ) > 0 )
				oTempR68:delete()
			endIf

			if( select( "R69" ) > 0 )
				oTempR69:delete()
			endIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Retorno																     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aRet := { .T.,cFileGerado }
		Endif
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gera tela de mensagem informativa na tela 							     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se todos os titulos foram baixados e informa 				     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  ( BRJ->BRJ_TPCOB == "1" .And. lTemBaixa1) .Or.;
		   	((BRJ->BRJ_TPCOB == "2" .Or. Empty(BRJ->BRJ_TPCOB)) .And. lTemBaixa1) .Or.;
			( BRJ->BRJ_TPCOB == "3" .And. lTemBaixa1 .And. lTemBaixa2)

		   		MsgInfo(STR0041,STR0024)//"NЦo possМvel gerar arquivo, constam titulos baixados no Financeiro"

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tipo 1 - NDC														     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf BRJ->BRJ_TPCOB == '1' .And.  !lTemBaixa1
		
			cChvSE1 := ""
			
			If BRJ->BRJ_NIV550 $ '3,5'   
				cChvSE1 := BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)
			ElseIf BRJ->BRJ_NIV550 == '7'
				cChvSE1 := BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP)
			EndIf
			
			If !Empty(cChvSE1)
			
				If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1))) 
					cMsg := STR0042+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo NDC:   "
				EndIf
	
				If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1))) 
					cMsg += ""+ Chr(13)+Chr(10)    
					cMsg += STR0042+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo NDC:   "
				EndIF
				
			EndIf

			MsgInfo(cMsg,STR0014)//,"Resumo"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tipo 2 - Fatura														     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf (BRJ->BRJ_TPCOB == '2' .Or. Empty(BRJ->BRJ_TPCOB)) .And. !lTemBaixa1   
			
			If BRJ->BRJ_NIV550 $ '3,5'
				If BRJ->BRJ_ARQPAR == "2"
					cChvSE1    := BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP)   
					cChvSE1Aba := BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+"AB-")
				Else
					cChvSE1    := BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)
					cChvSE1Aba := BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+"AB-")
				EndIf 
					
			ElseIf BRJ->BRJ_NIV550 == '7'
				cChvSE1 := BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP)
			EndIf
			
			SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1)))
			cMsg := STR0042+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo NDC:   "

			If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1Aba)))
				cMsg += ""+ Chr(13)+Chr(10)
				cMsg += STR0043+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)   //"TМtulo de CompensaГЦo NDC: "
			EndIf
			
			MsgInfo(cMsg,STR0014)//,"Resumo"
	   	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tipo 3 - Ambos (Com a NDC baixada)									     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   	ElseIf BRJ->BRJ_TPCOB == '3' .And. lTemBaixa1                                    				
	   	
	   		If !Empty(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))

				If SE1->( DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))))
					cMsg := STR0044+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo FAT: "
				EndIf

				If SE1->( DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+"AB-"))))
		   			cMsg += ""+ Chr(13)+Chr(10)
					cMsg += STR0045+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)  //"TМtulo de CompensaГЦo FAT: "
				EndIf
				
			EndIf

			MsgInfo(cMsg,STR0014)//,Resumo
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tipo 3 - Ambos (Com a Fatura baixada)								     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
		ElseIf BRJ->BRJ_TPCOB == '3' .And. lTemBaixa2  
		
			If !Empty(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))

			  	If SE1->( DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)))) 
					cMsg := STR0042+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo NDC:   "
				EndIf
 
 				If SE1->( DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+"AB-")))) 
					cMsg += ""+ Chr(13)+Chr(10)                                                                 
					cMsg += STR0043+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"TМtulo de CompensaГЦo NDC: "
				EndIf
	
			EndIf
			
	        MsgInfo(cMsg,STR0014)//,Resumo 
	    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tipo 3 - Ambos (Com ambos titulos Ok)								     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	 
	     ElseIf BRJ->BRJ_TPCOB == '3' .And. BRJ->BRJ_NIV550 $ '3,5' .And. !lTemBaixa1 .And. !lTemBaixa2   
            //Servicos
			cMsg := ""			
			If BRJ->BRJ_NIV550 $ "3/4" .And. BRJ->BRJ_ARQPAR == "2" 	 
				cChvSE1    := BRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+BRJ_NP2TIP)
				cChvSE1Aba := BRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+"AB-")
			Else
				cChvSE1    := BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)
				cChvSE1Aba := BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+"AB-")
			EndIf  
			
			If !Empty(cChvSE1)

				If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1))) 
					cMsg += STR0042+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo NDC:   "
				EndIf
 
 				If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1Aba))) 
					cMsg += ""+ Chr(13)+Chr(10)                                                                 
					cMsg += STR0043+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"TМtulo de CompensaГЦo NDC: "
				EndIf

			EndIf

	        //Taxas 
	        cMsg += ""+ Chr(13)+Chr(10) 
	        If BRJ->BRJ_NIV550 $ "3/4" .And. BRJ->BRJ_ARQPAR == "2" 	 
				cChvSE1    := BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP)     
				cChvSE1Aba := BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+"AB-")
			Else
				cChvSE1    := BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT) 
				cChvSE1Aba := BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+"AB-") 
			EndIf
			
			If !Empty(cChvSE1)

			    If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1)))
					cMsg += STR0044+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo FAT:   "
				EndIf
			
				If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1Aba)))
		   			cMsg += ""+ Chr(13)+Chr(10)
					cMsg += STR0045+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)  //"TМtulo de CompensaГЦo FAT: "
				EndIf
			
			EndIf
			
			MsgInfo(cMsg,STR0014)//,Resumo 

        ElseIf BRJ->BRJ_TPCOB == '3' .And. BRJ->BRJ_NIV550 == '7' .And. !lTemBaixa1 .And. !lTemBaixa2   

			cMsg := ""				

			If !Empty(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))

				If SE1->( DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP)))) 
					cMsg += STR0042+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo NDC:   "
				EndIf
 
 				If SE1->( DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+"AB-")))) 
					cMsg += ""+ Chr(13)+Chr(10)                                                                 
					cMsg += STR0043+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"TМtulo de CompensaГЦo NDC: "
				EndIf

			EndIf
	        
			cMsg += ""+ Chr(13)+Chr(10) 
			
			If !Empty(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))

			    If SE1->( DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))))
					cMsg += STR0044+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo FAT:   "
				EndIf
			
				If SE1->( DbSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+"AB-"))))
		   			cMsg += ""+ Chr(13)+Chr(10)
					cMsg += STR0045+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)  //"TМtulo de CompensaГЦo FAT: "
				EndIf
			
			EndIf
			
			MsgInfo(cMsg,STR0014)//,Resumo 
			  
		EndIf

	Endif

EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(aRet)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  ЁPLSUA560MRЁ Autor Ё  Tulio Cesar        Ё Data Ё 13.12.2002 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Cria uma vida para os marcados...                          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSUA560MR(nTipo)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL lRet	:=	.F.
LOCAL nX	:=	0   

Default nTipo = 1
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Executa tratamento para marcar...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

If nTipo = 1
	DbSelectArea("BRJ")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Checa se esta marcado													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If IsMark("BRJ_OK",cMarcaBRJ)  
		BRJ->(Reclock("BRJ",.F.))
		Replace BRJ_OK With "  "
		MsRUnLock( BRJ->( RECNO() ) )
	Else
		For nX	:=	0	To 1 STEP 0.2
			If MsRLock()
				Replace BRJ_OK With cMarcaBRJ
				nX	:=	1
				lRet:=	.T.
			Else
				Inkey(0.2)
			Endif
		Next
		If !lRet
			MsgAlert(OemToAnsi(STR0008)) //"Este registro esta em uso"
		Endif
	Endif
Else
	DbSelectArea("BTO")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Checa se esta marcado													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If IsMark("BTO_OK",cMarcaBto)
		Replace BTO_OK With "  "
		MsRUnLock( BTO->( RECNO() ) )
	Else
		For nX	:=	0	To 1 STEP 0.2
			If MsRLock()
				Replace BTO_OK With cMarcaBto
				nX	:=	1
				lRet:=	.T.
			Else
				Inkey(0.2)
			Endif
		Next
		If !lRet
			MsgAlert(OemToAnsi(STR0008)) //"Este registro esta em uso"
		Endif
	Endif

Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPLSA550VS Ё Autor Ё Alexander Santos      Ё Data Ё 03.01.07 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Visualiza registro exportados/importados					  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA560VS(cAlias,nReg,nOpc)
LOCAL I__f := 0
LOCAL oDlg
LOCAL oFolder
LOCAL oBrwB2A
LOCAL aCabB2A := {}
LOCAL aVetB2A := {}
LOCAL aDadB2A := {}
LOCAL aCampos := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega tabela de exportacao											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Store Header "B2A" TO aCabB2A For .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cols																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If B2A->( dbSeek(xFilial("B2A")+BTO->BTO_CODOPE+BTO->BTO_NUMTIT) )
	Store COLS "B2A" TO aDadB2A FROM aCabB2A VETTRAB aVetB2A While B2A->(B2A_FILIAL+B2A_CODOPE+B2A_NUMTIT) == xFilial("B2A")+BTO->(BTO_CODOPE+BTO_NUMTIT)
Else
	Store COLS Blank "B2A" TO aDadB2A FROM aCabB2A
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()

oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,aCampos,{015,001,117,356},aCampos,,,,,oDlg,,,.F.)

@ 120,003 FOLDER oFolder SIZE 350,075 OF oDlg  PIXEL PROMPTS STR0046//Questionamentos
oBrwB2A:= TPLSBrw():New(001,001,347,055,nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabB2A,aDadB2A,.F.,"B2A",K_Visualizar,STR0047,nil,nil,nil,aVetB2A)//Operadoras

ACTIVATE MSDIALOG oDlg ON INIT (Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End() },{||oDlg:End()},.F.)  }))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPLSLAR560 Ё Autor Ё Alexander Santos      Ё Data Ё 03.01.07 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Mostra diretorios										  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSLAR560(cDirExp)
LOCAL cDir := cDirExp
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Diretorio																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cDirExp := cGetFile("*.*",STR0019,0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checagem																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cDirExp)
	cDirExp := cDir
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSUA550VS╨Autor  ЁMicrosiga           ╨ Data Ё  12/04/10   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Aplica Filtro na Rotina									  ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSUA560VS
Local cPLSFiltro := ""

cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' AND BRJ_PREFIX <> ' ' "
cPLSFiltro += "AND BRJ_NUMTIT <> ' ' AND D_E_L_E_T_ = ' '"

PLSED500VS()

DbSelectArea("BRJ")
SET FILTER TO &cPLSFiltro

Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PL560EXEC  Ё Autor Ё                     Ё Data Ё 01.12.11 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Gera arquivo do 	Ajius									  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PL560EXECT()
LOCAL cDado
LOCAL cFileGerado
LOCAL lContinua  	:= .T.
LOCAL nTamMaxLay 	:= 0
LOCAL cDirFile		:= "\PTU\"
LOCAL aRet			:= {}
LOCAL aStru561		:= {}
LOCAL aStru562		:= {}
LOCAL aStru567		:= {}
LOCAL aStru568		:= {}
LOCAL aStru569		:= {}
LOCAL aCriticas		:= {}
LOCAL nFor 			:= 1    
LOCAL nFor2			:= 1
LOCAL aReg561		:={}
LOCAL aReg562		:={}
LOCAL aReg567		:={}
LOCAL aReg568		:={}
LOCAL aReg569		:={}
LOCAL nRegDE1561	:=0
LOCAL nRegDE1562	:=0  
LOCAL nRegDE1567	:=0
LOCAL nRegDE1568	:=0
LOCAL nRegDE1569	:=0
LOCAL nSeq			:=1    
LOCAL nCont         :=1
LOCAL cAliasTrb	:= GetNextAlias()
LOCAL nValorTit		:=0
LOCAL nValorTit1	:=0    
LOCAL cValDOC1      := ""
LOCAL cValDOC2      := ""   
LOCAL cNumDOC1      := Space(20)
LOCAL cNumDOC2      := Space(20)
LOCAL cNrNotDeb1    := ""
LOCAL cNrNotDeb2    := ""
LOCAL cMsg          := ""    
LOCAL cEmisDOC1     := Space(8)
LOCAL cEmisDOC2     := Space(8)   
LOCAL cVencDeb1     := Space(8)
LOCAL cVencDeb2     := Space(8)
LOCAL cArqPar       := ""
					
LOCAL aVetor		:={}
LOCAL cTipoTit		:=""
LOCAL nI          := 0
LOCAL nVlrDOC1    := 0
LOCAL nVlrDOC2    := 0
LOCAL cOpeOri     := ""
LOCAL cPrefNDC    := ""
LOCAL cTipoNDC    := ""  
LOCAL cNumero     := ""
LOCAL nID_ORI     := 0     
LOCAL cIndArqPar  := ""
LOCAL cNumTit     := ""		
LOCAL cNumNdc     := ""
Local cBanco    := Alltrim(Upper(TCGetDb()))
Local nDiasVcto     := GetNewPar("MV_PLVCTTC", 10)
Local lPLU560E1 := ExistBlock ("PLU560E1")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se layout existe...                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cDirFile := AllTrim(mv_par01)
cLayout  := PadR(mv_par02, 6)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa o diretorio														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If SubStr(cDirFile,Len(cDirFile),1) # "\"
	cDirFile+="\"
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё EDI																		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DE9->( DbSetOrder(1) )
If !DE9->( MsSeek( xFilial("DE9")+cLayout ) )
	AaDd( aCriticas,{"01",""} ) //"Arquivo de layout EDI A550 nao LOCALizado nas parametrizacoes do sistema."
	lContinua := .F.
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se ja foi gerado o titulo										 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BTO->BTO_NIV550 $ "3/4/5/6" .And. !Empty(BTO->BTO_GPFTIT) .Or. ;
   BTO->BTO_NIV550 $ "7/8" .And. !Empty(BTO->BTO_GCOTIT)
    
	 If !(BTO->BTO_ARQPAR == "2" .And. BTO->BTO_NIV550 $ "3/4" .And. Empty(BTO->BTO_GP2TIT))    
		AaDd( aCriticas,{"02","JА foi gerado tМtulo de cobranГa para este Lote."} ) //"Arquivo de layout EDI A550 nao LOCALizado nas parametrizacoes do sistema."
		lContinua := .F.   
	EndIf	
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Novo modelo de geracao Executora, indico na BTO os valores que minha     Ё  
//Ё operadora tem a receber ao importar o A550                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    nCont := 1 //Padrao um titulo
    cOpeOri := BTO->BTO_OPEORI
	If BTO->BTO_TPMOV == "1" //1=NDC     
    	If BTO->BTO_NIV550 $ "3/4/5/6"
    		If BTO->BTO_NIV550 $ "3/4" .And. BTO->BTO_ARQPAR == "2" 
				nVlrDOC1 :=  BTO->BTO_SLDGP2
			Else
				nVlrDOC1 :=  BTO->BTO_SLDGPF
			EndIf	
			
		ElseIf BTO->BTO_NIV550 $ "7/8" 
		    nVlrDOC1 := BTO->BTO_SLDGCO
		EndIf  
		cNumNdc := BTO->BTO_NUMTIT
		
	ElseIf Empty(BTO->BTO_TPMOV) .Or. BTO->BTO_TPMOV == "2" //2=Fatura     
		If BTO->BTO_NIV550 $ "3/4/5/6"   
			If BTO->BTO_NIV550 $ "3/4" .And. BTO->BTO_ARQPAR == "2" 
				nVlrDOC1  := BTO->BTO_SLDGP2
			Else
				nVlrDOC1  := BTO->BTO_SLDGPF
			EndIf	
			
	    ElseIf BTO->BTO_NIV550 $ "7/8" 
		    nVlrDOC1  := BTO->BTO_SLDGCO
	    EndIf 
	    cNumTit := BTO->BTO_NUMTIT
	    
	ElseIf BTO->BTO_TPMOV == "3" //3=Ambos  
		//Quando o Faturamento e para Ambos, vao existir dos BTOs
		aAreaBTO := BTO->(GetArea())
		BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
		cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
		If BTO->(DbSeek(cChaveBTO)) 
		  	nCont := 2 //Dois titulos
			While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 

			   	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©    
				//Ё Nova regra manual de intercambio (Flaga o BTO_TPMOV)   					 Ё
				//Ё 2 = DOC_1 (Valor do Item + Taxa Administrativa)     					 Ё
				//Ё 3 = DOC_1 (Taxa Administrativa) + DOC_2 (Valor do Item)					 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
				If BTO->BTO_TPCOB == "1" //NDC-Servicos -> DOC2
					If BTO->BTO_NIV550 $ "3/4/5/6"   
						If BTO->BTO_NIV550 $ "3/4" .And. BTO->BTO_ARQPAR == "2"  	
							nVlrDOC2 := BTO->BTO_SLDGP2 
						Else
							nVlrDOC2 := BTO->BTO_SLDGPF 
						EndIf	 
		   			ElseIf BTO->BTO_NIV550 $ "7/8" 
						nVlrDOC2 := BTO->BTO_SLDGCO 
		   			EndIf 	
				    cNumNdc := BTO->BTO_NUMTIT
				    
				ElseIf BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
				   	If BTO->BTO_NIV550 $ "3/4/5/6"
				   		If BTO->BTO_NIV550 $ "3/4" .And. BTO->BTO_ARQPAR == "2" 
			  				nVlrDOC1 := BTO->BTO_SLDGP2
			  			Else
			  				nVlrDOC1 := BTO->BTO_SLDGPF
			  			EndIf	
		   			ElseIf BTO->BTO_NIV550 $ "7/8" 
			   			nVlrDOC1 := BTO->BTO_SLDGCO
		   			EndIf 
		   			cNumTit := BTO->BTO_NUMTIT
				EndIf   
	
				BTO->(DbSkip())
			EndDo
		EndIf	
	    RestArea(aAreaBTO)
	EndIf  
		
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Novo modelo de geracao Executora, indico na BTO os valores que minha     Ё  
//Ё operadora tem a receber ao importar o A550                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lContinua     

	lContinua := .F. //Marco como falso, so vai setar novamente se houver geracao de titulo de cobranca
	For nI := 1 to nCont
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Novo modelo de geracao Executora, indico para o nValorTit o valor        Ё  
		//Ё de DOC1 ou DOC 2 correspondente                                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nI == 1 
			    nValorTit := nVlrDOC1
			Else
				nValorTit := nVlrDOC2
			EndIf
		
		If nValorTit > 0   
			lContinua := .T.
			                           
			SA1->( DbSetOrder(1) ) 
		    If BA0->(DbSeek(xFilial("BA0")+cOpeOri)) .And. SA1->(DbSeek(xFilial("SA1")+BA0->(BA0_CODCLI+BA0_LOJCLI)))
			
				cPrefNDC := &(GetNewPar("MV_PLPREE1",'"NDC"'))
				cTipoNDC := GetNewPar("MV_PLSTPCP","FT")
				cNumero  := NxtSX5Nota(cPrefNDC,.T.,"1",nil,"BK","PLS")
				
				lMsErroAuto:=.F.
				aVetor := {}	
				// Monta array com as informacoes do titulo
				aAdd(aVetor, {"E1_FILIAL" , xFilial("SE1")			, Nil})
			 	aAdd(aVetor, {"E1_PREFIXO", cPrefNDC				, Nil})
				aAdd(aVetor, {"E1_NUM"    , cNumero					, Nil})
				aAdd(aVetor, {"E1_PARCELA", ' '						, Nil})
				aAdd(aVetor, {"E1_TIPO"   , cTipoNDC				, Nil})
				aAdd(aVetor, {"E1_NATUREZ", SA1->A1_NATUREZ			, Nil})     
				aAdd(aVetor, {"E1_CLIENTE", SA1->A1_COD				, Nil})
				aAdd(aVetor, {"E1_LOJA"   , SA1->A1_LOJA			, Nil})
				aAdd(aVetor, {"E1_NOMCLI" , SA1->A1_NOME			, Nil})
				aAdd(aVetor, {"E1_EMISSAO", dDataBase				, Nil})
				aAdd(aVetor, {"E1_VENCTO" , dDataBase+nDiasVcto		, Nil})    
				aAdd(aVetor, {"E1_VENCREA", DataValida(dDataBase+nDiasVcto,.T.), Nil})
				aAdd(aVetor, {"E1_VALOR"  , nValorTit				, Nil})
				aAdd(aVetor, {"E1_HIST"   , "Processo Ajius "		, Nil})
				aAdd(aVetor, {"E1_ORIGEM" , "PLSUA560"				, Nil})
				aAdd(aVetor, {"E1_CODINT" , PlsIntPad()				, Nil})    
			 	aAdd(aVetor, {"E1_BASEIRF", 0				        , Nil})
				aAdd(aVetor, {"E1_BASEPIS", 0	     				, Nil})
				aAdd(aVetor, {"E1_BASECOF", 0						, Nil})
				aAdd(aVetor, {"E1_BASECSL", 0		        		, Nil})
				aAdd(aVetor, {"E1_BASEINS", 0	            		, Nil})     
				aAdd(aVetor, {"E1_BASEISS", 0		        		, Nil})
				aAdd(aVetor, {"E1_IRRF"	  , 0               		, Nil})
				aAdd(aVetor, {"E1_MULTNAT", "2"             		, Nil})
				aAdd(aVetor, {'E1_DECRESC', 0               		, Nil})
				aAdd(aVetor, {'E1_SDDECRE', 0               		, Nil})
				aAdd(aVetor, {'E1_ACRESC' , 0               		, Nil})
				aAdd(aVetor, {'E1_SDACRES', 0               		, Nil})
				aAdd(aVetor, {'E1_INSS'	  , 0               		, Nil})
				aAdd(aVetor, {'E1_COFINS' , 0               		, Nil})
				aAdd(aVetor, {'E1_PIS'	  , 0               		, Nil})
				aAdd(aVetor, {'E1_IRRF'	  , 0               		, Nil})
				aAdd(aVetor, {'E1_CSLL'	  , 0                		, Nil})
				aAdd(aVetor, {'E1_ISS'    , 0				 		, Nil})
				aAdd(aVetor, {'E1_VRETIRF', 0 						, Nil})
				
				If lPLU560E1
					aVetor:=ExecBlock ("PLU560E1",.F.,.F.,{aVetor})
					If ValType (aVetor) <>"A"
						MsgInfo (STR0050,STR0024)   //"Verificar retorno do Ponto de Entrada PLU560E1"                                                                                                                                                                                                                                                                                                                                                                                                       
					EndIf
				EndIf		
	
				msExecAuto({|x,y| Fina040(x,y)}, aVetor, 3) //Inclusao
					
				//If lMsErroAuto
				//	MOSTRAERRO()
				//Endif							
	
				//SE1->( ConfirmSx8() )	
				//lContinua:=.T. 
				
				
				If lMsErroAuto
					MOSTRAERRO()
					SE1->( RollBackSX8() )
					aRetTitOpe := {.F.,"","","",""}
				Else 
					SE1->( ConfirmSx8() )	
					lGerSE1 := .T.
					SE1->( ConfirmSx8() )
					aRetTitOpe := {.T.,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO}
					msgInfo(STR0034,STR0024)//"Criado Titulo no Financeiro com Sucesso!"
				Endif							
	
				lGerSE1 := aRetTitOpe[1]
	
				If lGerSE1
			
			 		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Ao gerar o Titulo sera informado no BD6 o numero do titulo gerado		 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды					
					cQryUpd := "UPDATE " + RetSqlName("BD6") + " SET"
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Tipos de cobranca (3-NDC Cobranca Complementar ou 1-NDC Cobranca Integral) Ё 
					//Ё nI = 1 - Taxas 					                                           Ё
					//Ё nI = 2 - Servicos               				                           Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
					If (BTO->BTO_TPMOV == '3' .And. nI == 2) .Or. BTO->BTO_TPMOV == '1'
						cQryUpd += " BD6_NDCPRE = '" +aRetTitOpe[2]+ "',"//cPrefixo
						cQryUpd += " BD6_NDCTIT = '" +aRetTitOpe[3]+ "',"//cNumero
						cQryUpd += " BD6_NDCPAR = '" +aRetTitOpe[4]+ "',"//cParcela
						cQryUpd += " BD6_NDCTIP = '" +aRetTitOpe[5]+ "' "//cTipo
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Tipos de cobranca (3-NDC Cobranca Complementar ou 2- NDC Cobranca Parcial) Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					ElseIf (BTO->BTO_TPMOV == '3' .And. nI == 1) .Or. BTO->BTO_TPMOV == '2'
						cQryUpd += " BD6_CONPRE = '" +aRetTitOpe[2]+ "', "//cPrefixo
						cQryUpd += " BD6_CONTIT = '" +aRetTitOpe[3]+ "', "//cNumero
						cQryUpd += " BD6_CONPAR = '" +aRetTitOpe[4]+ "', "//cParcela
						cQryUpd += " BD6_CONTIP = '" +aRetTitOpe[5]+ "'  "//cTipo
					EndIf

					cQryUpd += " WHERE BD6_FILIAL = '" +xFilial("BD6")+"' AND BD6_SEQPF = ' ' AND BD6_GUIORI <> ' ' AND "   
				             
					If BTO->BTO_TPMOV == '1'
						cQryUpd += " BD6_NDCTIT = ' ' AND "   
						cQryUpd += " BD6_NUMNDC = '"+cNumNdc+"' AND "
						
					ElseIf BTO->BTO_TPMOV == '2'
						cQryUpd += " BD6_CONTIT = ' ' AND "  
				    	cQryUpd += " BD6_NUMTIT = '"+cNumTit+"' AND "  
				    	
					ElseIf BTO->BTO_TPMOV == '3'
						If nI == 1
							cQryUpd += " BD6_CONTIT = ' ' AND " 
					 		cQryUpd += " BD6_NUMTIT = '"+cNumTit+"' AND " 
						Else
							cQryUpd += " BD6_NDCTIT = ' ' AND "
							cQryUpd += " BD6_NUMNDC = '"+cNumNdc+"' AND "
						EndIf
					EndIf
					
					cQryUpd += " D_E_L_E_T_ = ' ' "
					
					TCSQLEXEC(cQryUpd)
					If SubStr(cBanco,1,6) == "ORACLE"
						TCSQLEXEC("COMMIT")
					EndIf
				 
				   	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Ao gerar o Titulo sera informado no BTO o numero do titulo gerado		 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If nCont == 1      
						BTO->( RecLock("BTO",.F.) )	
						If BTO->BTO_NIV550 $ '3/4/5/6'    
							If BTO->BTO_NIV550 $ '3/4' .And. BTO->BTO_ARQPAR == "2" 
								BTO->BTO_GP2PRE := aRetTitOpe[2] //cPrefixo
								BTO->BTO_GP2TIT := aRetTitOpe[3] //cNumero
								BTO->BTO_GP2PAR := aRetTitOpe[4] //cParcela
								BTO->BTO_GP2TIP := aRetTitOpe[5] //cTipo  
							Else
								BTO->BTO_GPFPRE := aRetTitOpe[2] //cPrefixo
								BTO->BTO_GPFTIT := aRetTitOpe[3] //cNumero
								BTO->BTO_GPFPAR := aRetTitOpe[4] //cParcela
								BTO->BTO_GPFTIP := aRetTitOpe[5] //cTipo       
							EndIf	                   
						ElseIf BTO->BTO_NIV550 $ '7/8'
							BTO->BTO_GCOPRE := aRetTitOpe[2] //cPrefixo
							BTO->BTO_GCOTIT := aRetTitOpe[3] //cNumero
							BTO->BTO_GCOPAR := aRetTitOpe[4] //cParcela
							BTO->BTO_GCOTIP := aRetTitOpe[5] //cTipo
						EndIf 
						BTO->(MsUnlock())
					Else
					
						aAreaBTO := BTO->(GetArea())
						BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
						cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
						If BTO->(DbSeek(cChaveBTO)) 
						
			                If nI == 1 //Taxas - DOC1 
		                    	While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
		                    		If BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
		                    			BTO->( RecLock("BTO",.F.) )
		                    			If BTO->BTO_NIV550 $ '3/4/5/6'
		                    				If BTO->BTO_NIV550 $ '3/4' .And. BTO->BTO_ARQPAR == "2"
		                    					BTO->BTO_GP2PRE := aRetTitOpe[2] //cPrefixo
												BTO->BTO_GP2TIT := aRetTitOpe[3] //cNumero
												BTO->BTO_GP2PAR := aRetTitOpe[4] //cParcela
												BTO->BTO_GP2TIP := aRetTitOpe[5] //cTipo    
		                    				Else 
							   	   				BTO->BTO_GPFPRE := aRetTitOpe[2] //cPrefixo
												BTO->BTO_GPFTIT := aRetTitOpe[3] //cNumero
												BTO->BTO_GPFPAR := aRetTitOpe[4] //cParcela
												BTO->BTO_GPFTIP := aRetTitOpe[5] //cTipo                          
											EndIf	
										ElseIf BTO->BTO_NIV550 $ '7/8'
											BTO->BTO_GCOPRE := aRetTitOpe[2] //cPrefixo
											BTO->BTO_GCOTIT := aRetTitOpe[3] //cNumero
											BTO->BTO_GCOPAR := aRetTitOpe[4] //cParcela
											BTO->BTO_GCOTIP := aRetTitOpe[5] //cTipo
										EndIf
		                    			BTO->(MsUnlock())
		                    			Exit
		                    		EndIf 
		                    		BTO->(DbSkip())
				   				EndDo    	
			                Else //Servicos - DOC 2
			                	While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
		                    		If BTO->BTO_TPCOB == "1" //NDC-Servicos -> DOC2 
		                    			BTO->( RecLock("BTO",.F.) )
		                    			If BTO->BTO_NIV550 $ '3/4/5/6'
		                    				If BTO->BTO_NIV550 $ '3/4' .And. BTO->BTO_ARQPAR == "2"
		                    			   		BTO->BTO_GP2PRE := aRetTitOpe[2] //cPrefixo
												BTO->BTO_GP2TIT := aRetTitOpe[3] //cNumero
												BTO->BTO_GP2PAR := aRetTitOpe[4] //cParcela
												BTO->BTO_GP2TIP := aRetTitOpe[5] //cTipo   
		                    				Else
							   	   				BTO->BTO_GPFPRE := aRetTitOpe[2] //cPrefixo
												BTO->BTO_GPFTIT := aRetTitOpe[3] //cNumero
												BTO->BTO_GPFPAR := aRetTitOpe[4] //cParcela
												BTO->BTO_GPFTIP := aRetTitOpe[5] //cTipo                          
											Endif	
										ElseIf BTO->BTO_NIV550 $ '7/8'
											BTO->BTO_GCOPRE := aRetTitOpe[2] //cPrefixo
											BTO->BTO_GCOTIT := aRetTitOpe[3] //cNumero
											BTO->BTO_GCOPAR := aRetTitOpe[4] //cParcela
											BTO->BTO_GCOTIP := aRetTitOpe[5] //cTipo
										EndIf
		                    			BTO->(MsUnlock())
		                    			Exit
		                    		EndIf 
		                    		BTO->(DbSkip())
				   				EndDo    	    
			                EndIf
					   	RestArea(aAreaBTO)	
					   	EndIf
					EndIf	
				EndIf
			EndIf
	   	Endif	
	Next   
	If !lContinua
    	AaDd( aCriticas,{"05","NЦo foram encontrados valores para geraГЦo da cobranГa"} ) //"Arquivo de layout EDI A550 nao LOCALizado nas parametrizacoes do sistema."
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё checagem de regras... 												     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lContinua 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R561 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R561") )
		AaDd(aCriticas,{"04",STR0017}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0018}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1561 := DE1->( Recno() )
		cChave561  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R562 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R562") )
		AaDd(aCriticas,{"04",STR0012}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0005}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1562 := DE1->( Recno() )
		cChave562  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	          
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R567 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R567") )
		AaDd(aCriticas,{"04",STR0012}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0005}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1567 := DE1->( Recno() )
		cChave567  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif       
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R568 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R568") )
		AaDd(aCriticas,{"04",STR0012}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0005}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1568 := DE1->( Recno() )
		cChave568  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no tipo de registro R569 (Header)...                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE0->( DbSetOrder(1) )
	If !DE0->( DbSeek(xFilial("DE0")+cLayout+"R569") )
		AaDd(aCriticas,{"04",STR0012}) //"Arquivo de registro R561 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no primeiro campo deste tipo de registro...                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0005}) //"Nao encontrado campos para o tipo de registro R561."
		lContinua := .F.
	Else
		nRegDE1569 := DE1->( Recno() )
		cChave569  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	
	
	nSeq++
	DE1->( DbGoTo(nRegDE1561) )     
	SE1->(DbSetOrder(1))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Vou montar as variaveis necessarias							    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	If BTO->BTO_TPMOV == "1" //1=NDC     
		cValDOC1   := StrZero(BTO->BTO_CUSTOT*100,14) 
		cValDOC2   := Replicate("0",14)   
		If mv_par03 == 1 
			cNumDOC1   := PADR(BTO->BTO_PREFIX+" "+BTO->BTO_NUMTIT,20)
		Else
	        cNumDOC1   := strzero(val(BTO->BTO_NUMTIT),20) //cNumDOC1   := strzero(val(BTO->BTO_NUMTIT),11)
        EndIf
        //cNrNotDeb1 := StrZero(Val(Iif(BTO->BTO_NIV550$'3/4/5/6',BTO->BTO_GPFTIT,BTO->BTO_GCOTIT)),11)
        cNomDoc    := Alltrim(BTO->BTO_NUMTIT)     
        
        If SE1->(DbSeek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO->BTO_PARCEL+BTO->BTO_TIPTIT)))
        	cEmisDOC1 := Dtos(SE1->E1_EMISSAO)
        EndIf

   	ElseIf Empty(BTO->BTO_TPMOV) .Or. BTO->BTO_TPMOV == "2" //2=Fatura     
		cValDOC1 := StrZero(BTO->BTO_CUSTOT*100,14) 
		cValDOC2 := Replicate("0",14) 
		If mv_par03 == 1 
			cNumDOC1 := PADR(BTO->BTO_PREFIX+" "+BTO->BTO_NUMTIT,20)
		Else
			cNumDOC1 := strzero(val(BTO->BTO_NUMTIT),20) //strzero(val(BTO->BTO_NUMTIT),11)
		EndIf	
		//cNrNotDeb1 := StrZero(Val(Iif(BTO->BTO_NIV550$'3/4/5/6',BTO->BTO_GPFTIT,BTO->BTO_GCOTIT)),11)
		cNomDoc    := Alltrim(BTO->BTO_NUMTIT) 
		
		If SE1->(DbSeek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO->BTO_PARCEL+BTO->BTO_TIPTIT)))
        	cEmisDOC1 := Dtos(SE1->E1_EMISSAO)
        EndIf
				
	ElseIf BTO->BTO_TPMOV == "3" //3=Ambos  
		//Quando o Faturamento e para Ambos, vao existir dos BTOs
		aAreaBTO := BTO->(GetArea())
		BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
		cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
		If BTO->(DbSeek(cChaveBTO)) 
		  	nCont := 2 //Dois titulos
			While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 

			   	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©    
				//Ё Nova regra manual de intercambio (Flaga o BTO_TPMOV)   					 Ё
				//Ё 2 = DOC_1 (Valor do Item + Taxa Administrativa)     					 Ё
				//Ё 3 = DOC_1 (Taxa Administrativa) + DOC_2 (Valor do Item)					 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
				If BTO->BTO_TPCOB == "1" //NDC-Servicos -> DOC2
					cValDOC2 := StrZero(BTO->BTO_CUSTOT*100,14)  
					If mv_par03 == 1 
						cNumDOC2 := PADR(BTO->BTO_PREFIX+" "+BTO->BTO_NUMTIT,20)
					Else
			  			cNumDOC2 := strzero(val(BTO->BTO_NUMTIT),20) //cNumDOC2 := strzero(val(BTO->BTO_NUMTIT),11)
					EndIf	
					cNrNotDeb2 := StrZero(Val(Iif(BTO->BTO_NIV550$'3/4/5/6',BTO->BTO_GPFTIT,BTO->BTO_GCOTIT)),11)  
					
					If SE1->(DbSeek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO->BTO_PARCEL+BTO->BTO_TIPTIT)))
        				cEmisDOC2 := Dtos(SE1->E1_EMISSAO)
			        EndIf
				    
				ElseIf BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
			  		cValDOC1 := StrZero(BTO->BTO_CUSTOT*100,14) 
			  		If mv_par03 == 1  
				  		cNumDOC1 := PADR(BTO->BTO_PREFIX+" "+BTO->BTO_NUMTIT,20)    
				  	Else
				  		cNumDOC1 := strzero(val(BTO->BTO_NUMTIT),20) //cNumDOC1 := strzero(val(BTO->BTO_NUMTIT),11)
				  	EndIf	
			  		//cNrNotDeb1 := StrZero(Val(Iif(BTO->BTO_NIV550$'3/4/5/6',BTO->BTO_GPFTIT,BTO->BTO_GCOTIT)),11)   
			  		cNomDoc    := Alltrim(BTO->BTO_NUMTIT)       
			  		
			  		If SE1->(DbSeek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO->BTO_PARCEL+BTO->BTO_TIPTIT)))
			        	cEmisDOC1 := Dtos(SE1->E1_EMISSAO)
        			EndIf
        			
				EndIf   
	
				BTO->(DbSkip())
			EndDo
		EndIf	
	    RestArea(aAreaBTO)
	EndIf  
	cTipoArq := BTO->BTO_NIV550
	
	If BTO->BTO_NIV550 $ "3|4" .And. !Empty(BTO->BTO_ARQPAR)
		cArqPar  := BTO->BTO_ARQPAR
	Else
		cArqPar  := "0"
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Registro 561												    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave561
		
		If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"       //001 NR_SEQ
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(1,DE1->DE1_LAYTAM)})
	   
		ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"  //002 TP_REG
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"562" } )
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UNI_DES" // 003 CD_UNI_DES
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,BTO->BTO_OPEORI})
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UNI_ORI"   //004 CD_UNI_ORI
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,PLSINTPAD() } )
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO"     //006 RESERVADO
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(11)})  
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_TOT_DO1" //007 VL_TOT_ DOC_1
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO, cValDOC1 } )
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_VER_TRA" //008 NR_VER_TRA
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,&(DE1->DE1_REGRA)})
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO" //009 RESERVADO
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(11)})  
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_TOT_DO2" //010 VL_TOT_ DOC_2
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cValDOC2})
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tipo de Arquivo - TP_ARQUIVO 									Ё
		//Ё 	Regra:														Ё
		//Ё 	Quando o PTU A550 importado com o Tipo 5 ou 6:				Ё
		//Ё 		Gera: 1-NDC CobranГa Integral							Ё
		//Ё 	Quando o PTU A550 importado com o Tipo 3 ou 4:				Ё						
		//Ё 		Gera: 2-NDC CobranГa Parcial 							Ё
		//Ё 	Quando o PTU A550 importado com o Tipo 7 ou 8:				Ё			
		//Ё 		Gera: 3-NDC CobranГa Complementar                    	Ё				
		//Ё 																Ё
		//Ё     Obs.: Ao importar o A550 o tipo eh alimentado no BTO_NIV550 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   	ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_ARQUIVO" //011                                                                          
			If cTipoArq $ '3|4'
				AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"2" })
		    ElseIf cTipoArq $ '7|8'
				AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"3" })		    
			ElseIf cTipoArq $ '5|6'
				AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"1" }) 			    
			EndIf
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_DOC_1"   //012 NR_DOC_1
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cNumDOC1})   
	
		ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_DOC_2"//013 NR_ DOC_2
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cNumDOC2})	
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_ARQ_PAR" .And. cLayout >= "A560E" //014
			AaDd(aReg561,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cArqPar})
			
		Endif
			
		DE1->( DbSkip() )
	Enddo
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Registro 562												    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	For nI := 1 to nCont   
	
		AaDd( aReg562,{BD7->( Recno() ),{} } )
		nBottomArray := Len(aReg562)	
		DE1->( DbGoTo(nRegDE1562) )                         	
		nID_ORI++	
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Parcial / Fechamento 										    		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
		If Val(BTO->BTO_NIV550) < 7  
		
			If Empty(BTO->BTO_TPMOV) .Or. BTO->BTO_TPMOV == '2' 
				If cLayout >= "A560E" .And. BTO->BTO_ARQPAR == "2"
					SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GP2PRE+BTO_GP2TIT+BTO_GP2PAR+BTO_GP2TIP))))
					cNrNotDeb1 := StrZero(Val(BTO->BTO_GP2TIT),11)	
				Else
					SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP))))
					cNrNotDeb1 := StrZero(Val(BTO->BTO_GPFTIT),11)
			    EndIf
				cVencDeb1  := dtos(SE1->E1_VENCTO)       
					
			ElseIf BTO->BTO_TPMOV == '1'
				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP)))) 
	
				cNrNotDeb1 := StrZero(Val(BTO->BTO_GPFTIT),11)
				cVencDeb1  := dtos(SE1->E1_VENCTO) 
				
	        ElseIf BTO->BTO_TPMOV == '3' 
	        
        		aAreaBTO := BTO->(GetArea())
				BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
				cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
				If BTO->(DbSeek(cChaveBTO)) 
			    	While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
					   	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©    
						//Ё Nova regra manual de intercambio (Flaga o BTO_TPMOV)   					 Ё
						//Ё 2 = DOC_1 (Valor do Item + Taxa Administrativa)     					 Ё
						//Ё 3 = DOC_1 (Taxa Administrativa) + DOC_2 (Valor do Item)					 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
						If BTO->BTO_TPCOB == "1" //NDC-Servicos -> DOC2
					  		If cLayout >= "A560E" .And. BTO->BTO_ARQPAR == "2"
								SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GP2PRE+BTO_GP2TIT+BTO_GP2PAR+BTO_GP2TIP))))
								cNrNotDeb2 := StrZero(Val(BTO->BTO_GP2TIT),11)
							Else
								SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP))))
								cNrNotDeb2 := StrZero(Val(BTO->BTO_GPFTIT),11)
							EndIf 
						    cVencDeb2  := dtos(SE1->E1_VENCTO)
						    
						    
						ElseIf BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
					   		If cLayout >= "A560E" .And. BTO->BTO_ARQPAR == "2"
						   		SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GP2PRE+BTO_GP2TIT+BTO_GP2PAR+BTO_GP2TIP))))
								cNrNotDeb1 := StrZero(Val(BTO->BTO_GP2TIT),11)
								cVencDeb1  := dtos(SE1->E1_VENCTO)
						   	Else
						   		SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP))))
								cNrNotDeb1 := StrZero(Val(BTO->BTO_GPFTIT),11)
								cVencDeb1  := dtos(SE1->E1_VENCTO)
							EndIf        			
						EndIf   
						BTO->(DbSkip())
					EndDo 
				EndIf	 
				RestArea(aAreaBTO)		 
					 
			EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Complemento       	 										    		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
		Else
			
			If Empty(BTO->BTO_TPMOV) .Or. BTO->BTO_TPMOV == '2' 
				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP))))
			
				cNrNotDeb1 := StrZero(Val(BTO->BTO_GCOTIT),11)
				cVencDeb1  := dtos(SE1->E1_VENCTO)       
					
			ElseIf BTO->BTO_TPMOV == '1'
				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP)))) 
	
				cNrNotDeb1 := StrZero(Val(BTO->BTO_GCOTIT),11)
				cVencDeb1  := dtos(SE1->E1_VENCTO) 
				
	        ElseIf BTO->BTO_TPMOV == '3' 
	        
        		aAreaBTO := BTO->(GetArea())
				BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
				cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
				If BTO->(DbSeek(cChaveBTO)) 
			    	While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
					   	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©    
						//Ё Nova regra manual de intercambio (Flaga o BTO_TPMOV)   					 Ё
						//Ё 2 = DOC_1 (Valor do Item + Taxa Administrativa)     					 Ё
						//Ё 3 = DOC_1 (Taxa Administrativa) + DOC_2 (Valor do Item)					 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
						If BTO->BTO_TPCOB == "1" //NDC-Servicos -> DOC2
						
							SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP))))
							cNrNotDeb2 := StrZero(Val(BTO->BTO_GCOTIT),11)
							cVencDeb2  := dtos(SE1->E1_VENCTO)
						      
						    
						ElseIf BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
					   		SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP))))
							cNrNotDeb1 := StrZero(Val(BTO->BTO_GCOTIT),11)
							cVencDeb1  := dtos(SE1->E1_VENCTO)
							        			
						EndIf   
						BTO->(DbSkip())
					EndDo 
				EndIf	 
				RestArea(aAreaBTO)		 
					 
			EndIf
		EndIf     

		While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave562 
		   
			If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"       //001
				AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nSeq++,DE1->DE1_LAYTAM)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"  //002
				AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"562" } )      
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_NOTA_DB" // 003
				If nCont == 1 
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cNrNotDeb1})      
		  		ElseIf nCont == 2 .AND. nI == 1
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cNrNotDeb2})      			
				ElseIf nCont == 2 .AND. nI == 2
				 	AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cNrNotDeb1})     							
				EndIf
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_VEN_NT" //004
				If nCont == 1
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cVencDeb1})      
		  		ElseIf nCont == 2 .AND. nI == 1
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cVencDeb2})      			
				ElseIf nCont == 2 .AND. nI == 2
				 	AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cVencDeb1})     							
				EndIf  
		   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "ID_NDC_CON" //005    
				If nCont == 1
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"2"})      
		  		ElseIf nCont == 2 .AND. nI == 1
					AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"1"})      			
				ElseIf nCont == 2 .AND. nI == 2
				 	AaDd(aReg562[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"2"})     							
				EndIf  
		   
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Proximo																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DE1->( DbSkip() )
		Enddo   
				
		If Val(aReg562[nBottomArray,2,3,4]) == 0//na manda registro com valor zero
			aReg562 := {}
		EndIf

		DE1->( DbGoTo(nRegDE1562) )                         
	Next
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Registro 567												    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	For nI := 1 to 2   
	
		AaDd( aReg567,{BD7->( Recno() ),{} } )
		nBottomArray := Len(aReg567)	
		DE1->( DbGoTo(nRegDE1567) )                         	
		nID_ORI++	   
		
		If nI == 1
			BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
			BA0->(DbSeek(xFilial("BA0")+PLSINTPAD()))
		Else
			BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
			BA0->(DbSeek(xFilial("BA0")+BTO->BTO_OPEORI))
		EndIf
		
		While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave567 
		   
			If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"          //001 NЗmero seqЭencial de um registro em um arquivo de transferЙncia
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nSeq++,DE1->DE1_LAYTAM)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"      //002 Tipo de registro para os arquivos de troca de informaГУes batch.
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"567" } )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_CRED_DE"  //003 IdentificaГЦo do tipo de registro
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Iif(nI==1,"1","2") } )
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NM_CRED_DE"   //004 Nome completo da Credora ou Devedora
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Padr(BA0->BA0_NOMINT,60)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_ENDEREC"  //005 DescriГЦo do EndereГo
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Padr(BA0->BA0_END,40) } )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_END_CPL"  //006 DescriГЦo complementar do EndereГo
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Padr(BA0->BA0_COMPEN,20)} )   
					
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_END"     //007 NЗmero na via pЗblica.
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,IIf(Empty(BA0->BA0_NUMEND),Padr("S/N",6),padr(BA0->BA0_NUMEND,6))})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_BAIRRO"  //008 DescriГЦo do Bairro  
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,padr(BA0->BA0_BAIRRO,30)} )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_CEP"     //009 NЗmero do CEP
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,padr(BA0->BA0_CEP,8) } )       
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_CIDADE"  //010 DescriГЦo da Cidade
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,padr(BA0->BA0_CIDADE,30)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UF"      //011 CСdigo da Unidade Federativa
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,padr(BA0->BA0_EST,2)} )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_CNPJ_CP" //012 CСdigo do CNPJ ou CPF
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Val(BA0->BA0_CGC),14)} )  
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_DDD"     //013 NЗmero do DDD
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,strzero(val(iif(empty(BA0->BA0_DDD),substr(BA0->BA0_TELEF1,0,2),BA0->BA0_DDD)),4) })   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_FONE"    //014 NЗmero do Telefone
				cTel := cvaltochar(val(strtran(BA0->BA0_TELEF1,'-','')))
				strtran(BA0->BA0_FAX1  ,'-','')
				if empty(cTel)
					cTel := strzero(0,9)
				elseif empty(BA0->BA0_DDD) //Assumo que o DDD estА nesse campo e removo
					cTel := substr(cTel,3,len(cTel))
				endif

				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,strzero(val(substr(cTel,0,9)),9) } )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_FAX"     //015 NЗmero do fac-sМmile.
				AaDd(aReg567[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Iif(!Empty(BA0->BA0_FAX1 ),strzero(Val(strtran(BA0->BA0_FAX1  ,'-','')),9),strzero(0,9))} )   	 	
			EndIf	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Proximo																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DE1->( DbSkip() )
		Enddo   

		DE1->( DbGoTo(nRegDE1567) )                         
	Next    

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Registro 568												    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	For nI := 1 to nCont   
	
		AaDd( aReg568,{BD7->( Recno() ),{} } )
		nBottomArray := Len(aReg568)	
		DE1->( DbGoTo(nRegDE1568) )                         	
		nID_ORI++	   
		
		BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		BA0->(DbSeek(xFilial("BA0")+PLSINTPAD()))    
		SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Parcial / Fechamento 										    		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
		If Val(BTO->BTO_NIV550) < 7  
		
			If Empty(BTO->BTO_TPMOV) .Or. BTO->BTO_TPMOV == '2'  
				If cLayout >= "A560E" .And. BTO->BTO_NIV550 $ "3|4" .And. BTO->BTO_ARQPAR == "2"
					SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GP2PRE+BTO_GP2TIT+BTO_GP2PAR+BTO_GP2TIP))))   
				Else
					SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP))))   
				EndIf	
				cTipDoc := "2" 
			ElseIf BTO->BTO_TPMOV == '1'
				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP)))) 
				cTipDoc := "1"	
	        ElseIf BTO->BTO_TPMOV == '3' 
	        
        		aAreaBTO := BTO->(GetArea())
				BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
				cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
				If BTO->(DbSeek(cChaveBTO)) 
					
	                If nI == 1 //Taxas - DOC1 
                    	While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
                    		If BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
                    			If cLayout >= "A560E" .And. BTO->BTO_NIV550 $ "3|4" .And. BTO->BTO_ARQPAR == "2"
                    				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GP2PRE+BTO_GP2TIT+BTO_GP2PAR+BTO_GP2TIP))))
                    			Else
                    				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP))))
                    			EndIf
                    			cTipDoc := "2"
	        	        		Exit
	                    	EndIf 
	                    	BTO->(DbSkip())
	                    EndDo
	    			ElseIf nI == 2 //Taxas - DOC1 
                    	While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
                    		If BTO->BTO_TPCOB == "1" //Fatura-Taxas -> DOC1	  
                    			If cLayout >= "A560E" .And. BTO->BTO_NIV550 $ "3|4" .And. BTO->BTO_ARQPAR == "2"
                    				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GP2PRE+BTO_GP2TIT+BTO_GP2PAR+BTO_GP2TIP))))
                    			Else
                    				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP))))
                    			EndIf
                    			cTipDoc := "1"
	        	        		Exit
	                    	EndIf 
	                    	BTO->(DbSkip())
	                    EndDo
	    			EndIf
	       	    EndIf
	       	    RestArea(aAreaBTO)	
			EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Complemento       	 										    		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
		Else
		
			If Empty(BTO->BTO_TPMOV) .Or. BTO->BTO_TPMOV == '2' 
				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP))))   
				cTipDoc := "2" 
			ElseIf BTO->BTO_TPMOV == '1'
				SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP)))) 
				cTipDoc := "1"	
	        ElseIf BTO->BTO_TPMOV == '3' 
	        
        		aAreaBTO := BTO->(GetArea())
				BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
				cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
				If BTO->(DbSeek(cChaveBTO)) 
					
	                If nI == 1 //Taxas - DOC1 
                    	While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
                    		If BTO->BTO_TPCOB == "2" //Fatura-Taxas -> DOC1	  
                    			SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP))))
                    			cTipDoc := "2"
	        	        		Exit
	                    	EndIf 
	                    	BTO->(DbSkip())
	                    EndDo
	    			ElseIf nI == 2 //Taxas - DOC1 
                    	While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
                    		If BTO->BTO_TPCOB == "1" //Fatura-Taxas -> DOC1	  
                    			SE1->(DbSeek(xFilial("SE1")+Alltrim(BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP))))
                    			cTipDoc := "1"
	        	        		Exit
	                    	EndIf 
	                    	BTO->(DbSkip())
	                    EndDo
	    			EndIf
	       	    EndIf
	       	    RestArea(aAreaBTO)	
			EndIf		
		EndIf   
		
		If cTipDoc == "1"
			cLinha568 := Padr(&(GetNewPar("MV_PLL5681", "'Cobranca referente a Contestacao da NDR'")),74)
		Else
			cLinha568 := Padr(&(GetNewPar("MV_PLL5682", "'Cobranca referente a Contestacao da Fatura'")),74) 
		EndIf
		
		While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave568 
		   
			If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"          //001 NЗmero seqЭencial de um registro em um arquivo de transferЙncia.
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nSeq++,DE1->DE1_LAYTAM)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"      //002 Tipo de registro para os arquivos de troca de informaГУes batch.
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"568" } )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_EMI_NDC"  //003 Data de emissЦo da Nota de DИbito
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Dtos(SE1->E1_EMISSAO)} )//1-Credora   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_VEN_NDC"  //004 Data de vencimento da Nota de DИbito
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Dtos(SE1->E1_VENCTO)})   
				
			ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_LINHA"    //005 NЗmero da linha do item a ser impresso
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Strzero(nI,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )   
				   
			ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_LINHA"    //006 DescriГЦo da linha da Fatura
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cLinha568 } )   
					
			ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_NDC"      //007 Valor da Nota de DИbito 
	
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(SE1->E1_VALOR*100,DE1->(DE1_LAYTAM+DE1_LAYDEC)) })   

			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_DOC_568"  //008 Tipo de documento
				AaDd(aReg568[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cTipDoc} )   
			
			EndIf	   
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Proximo																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DE1->( DbSkip() )
		Enddo   

		DE1->( DbGoTo(nRegDE1568) )                         
	Next 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Registro 569												    		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
	AaDd( aReg569,{BD7->( Recno() ),{} } )
	nBottomArray := Len(aReg569)	
	DE1->( DbGoTo(nRegDE1569) )                         	
	nID_ORI++	   
		
	BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	BA0->(DbSeek(xFilial("BA0")+PLSINTPAD()))
		
	While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE1")+cChave569 
   
		If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"       //001
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nSeq++,DE1->DE1_LAYTAM)})   
			
		ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"  //002 Tipo de registro para os arquivos de troca de informaГУes batch.
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"569" } )   
			   
		ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO" .And. cLayout >= "A560D"//003 Reservado
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(11) } )
	   
		ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_EMI_DO1"   //004 Data de emissЦo do documento 1 - A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cEmisDOC1})   
				
		ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_TOT_DO1"  //005 Valor total do documento 1 - A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cValDOC1 } )   
			   
		ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO"//006 Reservado
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(11) } )   
			
		ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_EMI_DO2" //007 Data de emissЦo do documento 2 - A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cEmisDOC2 })
					
		ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_TOT_DO2"  //008 Valor total do documento 2 - A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cValDOC2 } )   
	   
		ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_DOC_1" //009 NЗmero do documento 1 - A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cNumDOC1 } )//1-Credora   
		
		ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_DOC_2" //010 NЗmero do documento 2 - A500
			AaDd(aReg569[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cNumDOC2 } )   
							
		EndIf	   
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Proximo																	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DE1->( DbSkip() )
	Enddo
	DE1->( DbGoTo(nRegDE1569) )                         
Endif   

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё So vai exportar caso nao tenha titulo gerado na SE1		    	         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	    
If lContinua 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se existe 	registro										 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Len(aReg562) > 0
		//здддддддддддддддддддд©
		//Ё TEMPORARIO 561     Ё
		//юдддддддддддддддддддды
		aadd(aStru561,{"CHAVE","C",022,0})
		aadd(aStru561,{"CAMPO" ,"C",113,0})
		
		//--< CriaГЦo do objeto FWTemporaryTable >---
		oTempR61 := FWTemporaryTable():New( "R61" )
		oTempR61:SetFields( aStru561 )
		oTempR61:AddIndex( "INDR61",{ "CHAVE" } )

		if( select( "R61" ) > 0 )
			R61->( dbCloseArea() )
		endIf

		oTempR61:Create()
		
		//здддддддддддддддддддд©
		//Ё TEMPORARIO 562     Ё
		//юдддддддддддддддддддды
		aadd(aStru562,{"CHAVE","C",022,0})
		aadd(aStru562,{"CAMPO" ,"C",031,0})

		//--< CriaГЦo do objeto FWTemporaryTable >---
		oTempR62 := FWTemporaryTable():New( "R62" )
		oTempR62:SetFields( aStru562 )
		oTempR62:AddIndex( "INDR62",{ "CHAVE" } )

		if( select( "R62" ) > 0 )
			R62->( dbCloseArea() )
		endIf

		oTempR62:Create()

		DbSelectArea( "R62" )
		R62->( dbSetorder( 1 ) )

		//здддддддддддддддддддд©
		//Ё TEMPORARIO 567     Ё
		//юдддддддддддддддддддды
		aadd(aStru567,{"CHAVE","C",022,0})
		aadd(aStru567,{"CAMPO" ,"C",244,0})

		//--< CriaГЦo do objeto FWTemporaryTable >---
		oTempR67 := FWTemporaryTable():New( "R67" )
		oTempR67:SetFields( aStru567 )
		oTempR67:AddIndex( "INDR67",{ "CHAVE" } )

		if( select( "R67" ) > 0 )
			R67->( dbCloseArea() )
		endIf

		oTempR67:Create()
		
		dbSelectArea( "R67" )
		R67->( dbSetorder( 1 ) )
		
		//здддддддддддддддддддд©
		//Ё TEMPORARIO 568     Ё
		//юдддддддддддддддддддды
		aadd(aStru568,{"CHAVE","C",022,0})
		aadd(aStru568,{"CAMPO" ,"C",118,0})
		
		//--< CriaГЦo do objeto FWTemporaryTable >---
		oTempR68 := FWTemporaryTable():New( "R68" )
		oTempR68:SetFields( aStru568 )
		oTempR68:AddIndex( "INDR68",{ "CHAVE" } )

		if( select( "R68" ) > 0 )
			R68->( dbCloseArea() )
		endIf

		oTempR68:Create()
		
		dbSelectArea( "R68" )
		R68->( dbSetorder( 1 ) )
		
		//здддддддддддддддддддд©
		//Ё TEMPORARIO 569     Ё
		//юдддддддддддддддддддды
		aadd(aStru569,{"CHAVE","C",022,0})
		aadd(aStru569,{"CAMPO" ,"C",117,0})
		
		//--< CriaГЦo do objeto FWTemporaryTable >---
		oTempR69 := FWTemporaryTable():New( "R69" )
		oTempR69:SetFields( aStru569 )
		oTempR69:AddIndex( "INDR69",{ "CHAVE" } )

		if( select( "R69" ) > 0 )
			R69->( dbCloseArea() )
		endIf

		oTempR69:Create()
		
		dbSelectArea( "R69" )
		R69->( dbSetorder( 1 ) )
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gera linha registro R561												 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cDado := ""
		For nFor := 1 To Len(aReg561)
			cDado += aReg561[nFor,4]
		Next
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava linha R561 no temporario											 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		R61->( RecLock("R61",.T.) )
		R61->CAMPO := cDado
		R61->( MsUnLock() )
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gera linha registro R562												 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nFor := 1 To Len(aReg562)
			cDado := ""
			For nFor2 := 1 to len(aReg562[nFor,2])
				cDado += aReg562[nFor,2,nFor2,4]
			Next nFor2
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava linha R562														 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			R62->( RecLock("R62",.T.) )
			R62->CAMPO := cDado
			R62->Chave := StrZero(nFor,19)+"562"
			R62->( MsUnLock() )
		Next
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gera linha registro R567												 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nFor := 1 To Len(aReg567)
			cDado := ""
			For nFor2 := 1 to len(aReg567[nFor,2])
				cDado += aReg567[nFor,2,nFor2,4]
			Next nFor2
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava linha R567														 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			R67->( RecLock("R67",.T.) )
			R67->CAMPO := cDado
			R67->Chave := StrZero(nFor,19)+"567"
			R67->( MsUnLock() )
		Next
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gera linha registro R568												 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nFor := 1 To Len(aReg568)
			cDado := ""
			For nFor2 := 1 to len(aReg568[nFor,2])
				cDado += aReg568[nFor,2,nFor2,4]
			Next nFor2
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava linha R568														 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			R68->( RecLock("R68",.T.) )
			R68->CAMPO := cDado
			R68->Chave := StrZero(nFor,19)+"568"
			R68->( MsUnLock() )
		Next
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gera linha registro R569												 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nFor := 1 To Len(aReg569)
			cDado := ""
			For nFor2 := 1 to len(aReg569[nFor,2])
				cDado += aReg569[nFor,2,nFor2,4]
			Next nFor2
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava linha R569														 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			R69->( RecLock("R69",.T.) )
			R69->CAMPO := cDado
			R69->Chave := StrZero(nFor,19)+"569"
			R69->( MsUnLock() )
		Next	     		

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicio do arquivo														 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		R62->( DbGoTop() )
		
		IIf(len(Alltrim(cNomDoc)) < 6,cFile := Alltrim(cNomDoc),cFile := SubStr(Alltrim(cNomDoc),Len(Alltrim(cNomDoc)) - 5, 6))
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Versao 6.0 completa com _ no inicio do nome do arquivo					 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If cLayout >= "A560D" .And. len(cFile) < 6
			cFile := Replicate("_",6-len(cFile)) + cFile
		EndIf
		
		If BTO->BTO_NIV550 $ "3/4"
			cTipo := "2_"
		ElseIf BTO->BTO_NIV550 $ "5/6"
			cTipo := "1_"
		ElseIf BTO->BTO_NIV550 $ "7/8"
			cTipo := "3_"
		EndIf        
		
		If cLayout >= "A560E" .And. BTO->BTO_NIV550 $ "3|4" .And. !Empty(BTO->BTO_ARQPAR)   
           	cIndArqPar := "_"+BTO->BTO_ARQPAR
		EndIf		
			
		cFileGerado := Upper(cDirFile+"ND"+ cTipo + cFile +cIndArqPar+"."+SubStr(PLSINTPAD(), 2, 3))
		cArqNom		:= Upper("ND"+ cTipo + cFile +cIndArqPar+"."+SubStr(PLSINTPAD(), 2, 3))
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava																	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		R62->(DbGoTop())
		R67->(DbGoTop())
		R68->(DbGoTop())
		R69->(DbGoTop())
		If  ! R62->(EOF())
			PTULn("561",.T.)
			PlsPTU(padr(mv_par02,6),cArqNom,cDirFile)
		Endif
		
		if( select( "R61" ) > 0 )
			oTempR61:delete()
		endIf

		if( select( "R62" ) > 0 )
			oTempR62:delete()
		endIf

		if( select( "R67" ) > 0 )
			oTempR67:delete()
		endIf

		if( select( "R68" ) > 0 )
			oTempR68:delete()
		endIf

		if( select( "R69" ) > 0 )
			oTempR69:delete()
		endIf
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Retorno																     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aRet := { .T.,cFileGerado }
	Endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gera tela de mensagem informativa na tela 							     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
  	If BTO->BTO_TPMOV <> '3'
			
		If BTO->BTO_NIV550 $ '3/4/5/6'     
			If BTO->BTO_NIV550 $ "3/4" .And. BTO->BTO_ARQPAR == "2" 
				cChvSE1 := BTO->(BTO_GP2PRE+BTO_GP2TIT+BTO_GP2PAR+BTO_GP2TIP)
			Else			
				cChvSE1 := BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP)
			EndIf	
		ElseIf BTO->BTO_NIV550 $ '7/8'
			cChvSE1 := BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP)
		EndIf
			
		If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1)))
			cMsg := "TМtulo gerado: "+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo NDC:   "
        EndIf
        
		MsgInfo(cMsg,STR0014)//,Resumo     
	Else
	
		aAreaBTO := BTO->(GetArea())
		BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
		cChaveBTO := BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI)
		If BTO->(DbSeek(cChaveBTO)) 
			While BTO->(BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI) == cChaveBTO .And. !BTO->(Eof()) 
				If BTO->BTO_NIV550 $ '3/4/5/6'
					If BTO->BTO_NIV550 $ "3/4" .And. BTO->BTO_ARQPAR == "2" 
						cChvSE1 := BTO->(BTO_GP2PRE+BTO_GP2TIT+BTO_GP2PAR+BTO_GP2TIP) 
					Else
						cChvSE1 := BTO->(BTO_GPFPRE+BTO_GPFTIT+BTO_GPFPAR+BTO_GPFTIP) 
					EndIf	
					If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1)))
						cMsg += "TМtulo gerado: "+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo NDC:   "
					EndIf
				ElseIf BTO->BTO_NIV550 $ '7/8'
					cChvSE1 := BTO->(BTO_GCOPRE+BTO_GCOTIT+BTO_GCOPAR+BTO_GCOTIP)    
					If SE1->( DbSeek(xFilial("SE1")+Alltrim(cChvSE1)))
						cMsg += "TМtulo gerado: "+SE1->E1_PREFIXO+" " +SE1->E1_NUM+" "+SE1->E1_TIPO+ Chr(13)+Chr(10)//"Titulo de ContestaГЦo NDC:   "
					EndIf
				EndIf	
				
				BTO->(DbSkip())
			EndDo
			MsgInfo(cMsg,STR0014)//,Resumo     
		EndIf
		RestArea(aAreaBTO)	
		
	EndIf       

ElseIf Len(aCriticas) > 0
	aRet := {.F.,aCriticas}
EndIf

Return(aRet)
