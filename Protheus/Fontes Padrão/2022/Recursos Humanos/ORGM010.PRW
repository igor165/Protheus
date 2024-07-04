#INCLUDE "PROTHEUS.CH"
#INCLUDE "ORGM010.CH"
                                               
Static aAcho
Static aAlter

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁVariavel para manipulacao do calendario apos sua montagem	  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static lIncPosto := ExistBlock( "ORGMSOL1" )

/*ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma     Ё ORGM010  Ё Autor Ё Equipe IP-RH          Ё Data Ё 25/09/06 Ё╠╠
╠╠цдддддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o    Ё Cadastro de Movimento Departamento                         Ё╠╠
╠╠цдддддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso          Ё SigaOrg - Arquitetura Organizacional                       Ё╠╠
╠╠цдддддддддддддеддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data   Ё BOPS Ё  Motivo da Alteracao                       Ё╠╠  
╠╠цдддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠ 
╠╠ЁCecilia Carv.Ё01/08/14ЁTQEIB9ЁIncluido o fonte da 11 para a 12 e efetuada Ё╠╠
╠╠Ё             Ё        Ё      Ёa limpeza.                                  Ё╠╠
╠╠ЁMariana M.   Ё05/01/15ЁTRGHMMЁInclusao do PE ORG10CON na funГЦo OrgM10Con-Ё╠╠
╠╠Ё             Ё        Ё      Ёfirma , conforme solicitaГЦo de replica     Ё╠╠
╠╠ЁHenrique V.  Ё13/01/15ЁTRFZQNЁAjuste para que o sistema preencha o campo  Ё╠╠
╠╠Ё             Ё        Ё      Ё⌠Loc. Pago■ apСs preencher o ⌠Cod. Lc. Pg.■ Ё╠╠
╠╠Ё             Ё        Ё      Ёna inclusЦo e alteraГЦo. MEXICO             Ё╠╠
╠╠ЁFlavio C.    Ё27/07/15ЁPCDEF-50796ЁRespeitar parametro MV_APRPOST         Ё╠╠
╠╠ЁMarcelo FariaЁ10/02/17ЁMRH-6513   ЁAjuste para que o sistema preencha o campo  Ё╠╠
╠╠Ё             Ё        Ё           Ё⌠Loc. Pago■ apСs preencher o ⌠Cod. Lc. Pg.■ Ё╠╠

╠╠юдддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠ 
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/

/*
╠╠иммммммммммяммммммммммямммммммяммммЁ╠╠
╠╠ЁData Fonte SustentaГЦoЁ ChangeSet Ё╠╠
╠╠ЁддддддддддддаддддддддаддддддддддддЁ╠╠  
╠╠Ё    13/02/2015        Ё  284751   Ё╠╠ 
╠╠иммммммммммяммммммммммямммммммяммммм╠╠
*/
Function ORGM010()

	Private cCadastro 	:= STR0001	//"ManutenГЦo"
	Private cDelFunc 	:= ".T."	
	Private lIntRSP	:= GetMv("MV_IORGRSP", NIL, "0") == "1"
		
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta um aRotina proprio                                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Private aRotina 	:= MenuDef()
	Private oObjMBrw 	:= GetObjBrow()
	default aAcho := GetRBTFields(.T.)
	default aAlter := GetRBTFields(.F.)
	Private nRbtMovTam 	:= GetSx3Cache( "RBT_CODMOV" , "X3_TAMANHO" )
	/*
	VALIDAгцO DE COMPARTILHAMENTO DE TABELAS RCL E SQB
	*/
	If FindFunction("fVldCompt")
		If !fVldCompt()
			Return .F.
		EndIf
	EndIf	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSelectArea("RBT")     
	dbSetOrder(4)
	
	RBT->(dbGoTop())
	MBrowse(6, 1, 22, 75, "RBT", , , , , , Orgm10CriaCor())
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁORGM10Inc ╨Autor  ЁMarcos Alves        ╨ Data Ё  01/11/07   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Incluisao de solicitaГЦo de postos	 					  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAORG                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function ORGM10Inc(cAlias,nReg,nOpc)	

Local bBlkInc	:= {}
Local lAprova	:= SuperGetMV("MV_APRPOST",NIL,"S") == "S" //Se utiliza rotina de aprovaГЦo de posto
Local lIntRSP	:= SuperGetMv("MV_IORGRSP",NIL,"0") == "1" 
Local lRet		:= .F.
Local nRet		:= 0
Local nResp		:= 0

DEFAULT aAcho := GetRBTFields(.T.)
DEFAULT aAlter := GetRBTFields(.F.)
DEFAULT lIncPosto := ExistBlock( "ORGMSOL1" )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Ponto de Entrada 								               Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
bBlkInc := { || If( lIncPosto, ExecBlock("ORGMSOL1",.F.,.F., { RBT->RBT_FILIAL, RBT->RBT_CODMOV } ), .T. ) }

nRet := AxInclui("RBT", nReg, nOpc, aAcho, NIL, aAlter, "GA1040TudOk()",,,,{{||.T.},{||.T.},{||.T.},bBlkInc } )

If !lAprova .and. nRet == 1
	
	If lIntRSP

		// Quando o tipo do posto for generico e for alteracao de aumento de quadro, envia direto para o RSP
		If RBT->RBT_TPOSTO == '2' .And. RBT->RBT_TIPOR == "2"
			nResp := 1
		Else
			nResp := Aviso(STR0027,;
							STR0044,;
							{STR0021,STR0022},2,;
							STR0023) //"AtenГЦo"###"Deseja abrir a(s) vaga(s) no mСdulo de Recrutamento e SeleГЦo para o(s) posto(s) aprovado(s)?"###"Sim"###"NЦo"###"Confirma operaГЦo"
		EndIf

	EndIf
		    
	lRet:=OrgXAprova( RBT->RBT_FILIAL, RBT->RBT_CODMOV, "1", RBT->RBT_QTDMOV, "01", nResp == 1, , RBT->RBT_DEPTO )

	If lRet
		If ExistBlock( "ORG10CON" )	
			ExecBlock("ORG10CON",.F.,.F.)     
		EndIf
	EndIf
EndIf

Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁORGM10Alt ╨Autor  ЁMarcos Alves        ╨ Data Ё  01/11/07   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Inclusao  das solicitacoes de postos, que nЦo foram manipu-╨╠╠
╠╠╨          Ё ladas.                                                     ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAORG                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function ORGM10Alt(cAlias,nReg,nOpc)  
	default aAcho := GetRBTFields(.T.)
	default aAlter := GetRBTFields(.F.)
	
	If RBT->RBT_STATUS=="3"
		AxAltera(cAlias, nReg, nOpc,aAcho, aAlter, NIL,, "GA1040TudOk()")
	Else
		Aviso(STR0027,STR0008,{"Ok"},2,STR0009)//"AtenГЦo"#"MovimentaГЦo ja foi manipulada"#"Nao И permitido AlteraГЦo"
	EndIf	
Return NIL

Function ORGM10Vis(cAlias,nReg,nOpc)  
	default aAcho := GetRBTFields(.T.)
	
	AxVisual(cAlias, nReg, nOpc, aAcho)
Return NIL


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁORGM10Exc ╨Autor  ЁMarcos Alves        ╨ Data Ё  01/11/07   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Exclusao  das solicitacoes de postos, que nЦo foram manipu-╨╠╠
╠╠╨          Ё ladas.                                                     ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAORG                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function ORGM10Exc(cAlias,nReg,nOpc)

	If RBT->RBT_STATUS=="3"
		AxDeleta(cAlias, nReg, nOpc)
	Else
		Aviso(STR0027,STR0008,{"Ok"},2,STR0009)//"AtenГЦo"#"MovimentaГЦo ja foi manipulada"#"Nao И permitido AlteraГЦo"
	EndIf

Return 

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммяммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁOrgm10CriaCor ╨Autor  ЁMarcos Alves    ╨ Data Ё  01/11/07   ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммоммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Definicao das cores da mbrowse                             ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAORG                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function Orgm10CriaCor()

Local aCores	:=	{{"RBT->RBT_STATUS  = '1'",'BR_VERMELHO'},;	// baixados
					 {"RBT->RBT_STATUS  = '2'",'BR_AMARELO'},;	// Pendente parcial
					 {"RBT->RBT_STATUS  = '3'",'BR_VERDE'}}  	// Pendente total

Return(aCores)
/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁOrga060MntЁ Autor ЁMarcos Alves           Ё Data Ё12/11/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁOperacao de movimentacoes de departamentos                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁOrga060()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function ORGM10Oper( cAlias , nReg , nOpc , lDlgPadSiga , nOpcNewGd )
Local aArea			:= GetArea(Alias())
Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local bGdLeg		:= { || NIL }

Local bGetRbx
Local aRbxHeader	:= {}
Local aRbxCols		:= {}
Local aRbxFields	:= {}
Local aRbxAltera	:= {}
Local aRbxNaoAlt	:= {}
Local aRbxVirtEn	:= {}
Local aRbxNotFields	:= {}
Local aRbxRecnos	:= {}
Local aRbxKeys		:= {}
Local aRbxVisuEn	:= {}
Local cRbxKey		:= xFilial("RBX")+RBT->RBT_DEPTO+RBT->RBT_CODMOV
Local nRbxUsado		:= 0
Local oEnRbx		:= NIL
Local aRbxGetHeader	:={}
Local oGdRbx

Local bGetRcl
Local aRclHeader	:= {}
Local aRclCols		:= {}
Local aRclFields	:= {}
Local aRclAltera	:= {}
Local aRclNaoAlt	:= {}
Local aRclVirtEn	:= {}
Local aRclNotFields	:= {}
Local aRclRecnos	:= {}
Local aRclKeys		:= {}
Local aRclVisuEn	:= {}
Local cRclKey		:= xFilial("RCL")+RBT->RBT_DEPTO
Local nRclUsado		:= 0

Local aButtons		:= {}
//Local bSet15		:=	{||	OrgM10Confirma(	bGetRbx,aRbxHeader,aRbxCols,nRbxUsado,oGdRbx,;
//											bGetRcl,aRclHeader,aRclCols,nRclUsado,oGdRcl,;
//											aRbxGetHeader)}


						
Local bSaveOper:=	{||	SetKey(VK_F6, bSaveOper), OrgM10Confirma(	bGetRbx,;
																	aRbxHeader,;
																	aRbxCols,;
																	nRbxUsado,;
																	oGdRbx,;
																	bGetRcl,;
																	aRclHeader,;
																	aRclCols,;
																	nRclUsado,;
																	oGdRcl,;
																	aRbxGetHeader)}
						
Local bSet15		:=	{ || If(M->RBX_QTDISP >0, If( Eval(bSaveOper), oDlg:End(), NIL), oDlg:End() )	}
//RBX_QTDOPE RBX_QTDISP


Local bSet24		:=	{ || oDlg:End()	}
Local bDialogInit	:=	{ || NIL }

Local lLocks		:= .F.
Local lExecLock		:= ( ( nOpc <> 2 ) .and. ( nOpc <> 3 ) )
Local nLoop			:= 0
Local nLoops		:= 0

Local oDlg			:= NIL
Local oFolders		:= NIL
Local aFolders		:= Array( 02 )
Local aPages		:= Array( 02 )
Local aObjFolder	:= Array( 02 )
Local aGdObjects	:= {}
Local nActFolder	:= 0
Local nNewFolder	:= 1		

Private aGets		:= {}
Private aTela		:= {}
Private nGetSX8Len  := GetSX8Len()

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Define o Conteudo do aFolders								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
aFolders[ 01 ] 		:= "&" + STR0016	//Movimentos
If cPaisLoc=="RUS"
	aFolders[ 02 ]	:= "&" + STR0047	//Stations
Else
	aFolders[ 02 ]	:= "&" + STR0017	//Postos
EndIf


/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Define o Conteudo do aPages								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
aPages[ 01 ]   		:= "&" + STR0016	//Movimentos
If cPaisLoc=="RUS"
	aPages[ 02 ]	:= "&" + STR0047	//Stations
Else
	aPages[ 02 ]	:= "&" + STR0017	//Postos
Endif
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Define os Elementos para o Array do Objeto Folder        	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
aObjFolder[ 01 ]	:= Array( 01 , 03 )
aObjFolder[ 02 ]	:= Array( 01 , 03 )

cAlias				:= "RBX"
nOpc				:= 4

Begin Sequence
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Coloca o ponteiro do Cursor do Mouse em Estado de Espera     Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorWait()
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁCheca a Opcao Selecionada									   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	aRotSetOpc( cAlias , @nReg , nOpc )
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta os Dados para a Enchoice							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	aRbxNotFields	:= 	{"RBX_FILIAL", "RBX_RESOPE","RBX_QTDMOV","RBX_QTDISP", "RBX_CODOPE"}
	aRbxVisuEn		:=	{"RBX_CODOPE" }

	/*                                                                   1
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Cria a Coluna "COLBMP" de NewGetdados do RBX				   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	aFieldsRbxAux		:= { { "COLBMP"		, "ORGM10ShowLegend('RBX', 'G')"} }
	bGetRbx			:= 	{ |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aRbxKeys := NIL ),;
										aRbxCols := RBX->(;
															GdBuildCols(	@aRbxHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																			@nRbxUsado		,;	//02 -> Numero de Campos em Uso
																			@aRbxVirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																			@aRbxVisuEn		,;	//04 -> [@]Array com os Campos Visuais
																			"RBX"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																			aRbxNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																			@aRbxRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																			"RBX"		   	,;	//08 -> Alias do Arquivo Pai
																			cRbxKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
																			NIL				,;	//10 -> Bloco para condicao de Loop While
																			NIL				,;	//11 -> Bloco para Skip no Loop While
																			NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																			NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																			NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																			NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																			NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																			NIL				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																			NIL				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																			aFieldsRbxAux	,;	//19 -> Carregar Coluna Fantasma
																			NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																			NIL				,;	//21 -> Verifica se Deve verificar se o campo eh usado
																			NIL				,;	//22 -> Verifica se Deve verificar o nivel do usuario
																			NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																			@aRbxKeys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																			@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																			@lExclu			 ;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																	    );
														  ),;
										IF( lExecLock , ( lLock .and. lExclu ) , .T. );
	  					} 
    RBX->(dbSetOrder(2))
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁLock do Registro do Rbx									   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !( lLocks := WhileNoLock( "RBX" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRbx ) )
		Break
	EndIF
	CursorWait()
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Gerar um novo aHeader para o MSMGET, diferente da coluna da  Ё
	Ё MSNEWGETDADOS												   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	aRbxGetHeader  := GdMontaHeader(NIL,NIL, NIL, "RBX",{"RBX_FILIAL", "RBX_RESOPE", "RBX_CODPOS", "RBX_TIPOR"})
	/*                                                                   
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carregando campos Alteraveis e Editavies					   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	MkArrEdFlds( nOpc , aRbxGetHeader , aRbxVisuEn , aRbxVirtEn , @aRbxNaoAlt , @aRbxAltera , @aRbxFields )
	/*                                                  
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Reinicializa as variavais criadas							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	Orgm10InitVar(aRbxGetHeader)
	/*                                                                   
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Cria a Coluna "COLBMP" de NewGetdados do RCL				   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	aFieldsRclAux		:= { { "COLBMP"		, "ORGM10ShowLegend('RCL','G')"} }
    RCL->(dbSetOrder(4))
	bGetRcl			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aRclKeys := NIL ),;
										aRclCols := RCL->(;
															GdBuildCols(	@aRclHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																			@nRclUsado		,;	//02 -> Numero de Campos em Uso
																			@aRclVirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																			@aRclVisuEn		,;	//04 -> [@]Array com os Campos Visuais
																			"RCL"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																			aRclNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																			@aRclRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																			"RCL"		   	,;	//08 -> Alias do Arquivo Pai
																			cRclKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
																			NIL				,;	//10 -> Bloco para condicao de Loop While
																			NIL				,;	//11 -> Bloco para Skip no Loop While
																			NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																			NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																			NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																			NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																			NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																			NIL				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																			NIL				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																			aFieldsRclAux	,;	//19 -> Carregar Coluna Fantasma
																			NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																			NIL				,;	//21 -> Verifica se Deve verificar se o campo eh usado
																			NIL				,;	//22 -> Verifica se Deve verificar o nivel do usuario
																			NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																			@aRclKeys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																			@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																			@lExclu			 ;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																	    );
														  ),;
										IF( lExecLock , ( lLock .and. lExclu ) , .T. );
	  					} 

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁLock do Registro do Rbx									   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !( lLocks := WhileNoLock( "RCL" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRcl ) )
		Break
	EndIF
	CursorWait()
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Cria as Variaveis de Memoria e Carrega os Dados Conforme o arЁ
	Ё quivo														   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	For nLoop := 1 To nRclUsado
		SetMemVar( aRclHeader[ nLoop , 02 ] , aRclCols[ 01 , nLoop ] , .T. )
	Next nLoop
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta as Dimensoes dos Objetos         					   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	DEFAULT lDlgPadSiga	:= .F.
	aAdvSize		:= MsAdvSize( NIL , lDlgPadSiga )
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000, 060, .T. , .F. } )
	aAdd( aObjCoords , { 000, 000, .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	bGdLeg := { ||	ORGM10ShowLegend(If(nActFolder=1,"RBX","RCL"))	,;
					SetKey( VK_F5 , bGdLeg ) ;
			   }
	aAdd(;
			aButtons	,;
							{;
								"PMSCOLOR"							,;
	   							bGdLeg								,;
	       	   					OemToAnsi( STR0007+ "...<F5>"  )	,;	//"Legenda"
	       	   					OemToAnsi( STR0007)			 	;		//"Legenda"
	           				};
	     )

	//bSaveOper := { ||		,;
	//			  		SetKey( VK_F6 , bSaveOper ) ;
    //			   }
	aAdd(;
			aButtons	,;
							{;
								"SALVAR",;
	   							bSaveOper,;
	       	   					OemToAnsi( STR0038 + "...<F6>"  )	,;	//"Gravar"
	       	   					OemToAnsi( STR0038)			 	;		//"Gravar"
	           				};
	     )
	     
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define o Bloco para a Inicializacao do Dialog            	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	bDialogInit		:= { ||;
								aObjFolder[01,01,01] := oGdRbx							,;
								aObjFolder[01,01,02] := { || .T. }						,;
								aObjFolder[01,01,03] := NIL								,;
								aObjFolder[02,01,01] := oGdRcl							,;
								aObjFolder[02,01,02] := { || .T. }						,;
								aObjFolder[02,01,03] := NIL								,;
								EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons )	,;
					 	 		SetKey( VK_F5 , bGdLeg )								,;
					 	 		FolderSetOption( nNewFolder , oFolders:nOption , aObjFolder , @aGdObjects , @nActFolder );
					   }
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Limpa a linha do browse, caso nЦo exista registros nas tabelaЁ
	Ё RBX e RCL 												   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	Orgm10ClearBrw(aRbxHeader,aRbxCols)
	Orgm10ClearBrw(aRclHeader,aRclCols)
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Restaura o Ponteiro do Cursor do Mouse                  	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorArrow()
    /*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta o Dialogo Principal para a Manutencao das Formulas	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega o Objeto Folder               					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		oFolders := TFolder():New(	aObjSize[ 2 , 1 ]		,;
									aObjSize[ 2 , 2 ]		,;
									aFolders				,;
									aPages					,;
									oDlg					,;
									NIL						,;
									NIL						,;
									NIL						,;
									.T.						,;
									.F.						,;
									aObjSize[ 2 , 4 ]		,;
									aObjSize[ 2 , 3 ]-70	 ;
								 )
		oFolders:bSetOption := { |nNewFolder| FolderSetOption( nNewFolder , oFolders:nOption , aObjFolder , @aGdObjects , @nActFolder ) }
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Se quantidade disponivel for zero, nao libera edicao (Visual)Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		nOpc:=If(M->RBX_QTDISP>0,3,2)
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto Enchoice para o Rbx                      	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		oEnRbx	:= MsmGet():New(	cAlias		,;		//01
									nReg		,;		//02      	
									nOpc		,;		//03
									NIL			,;		//04
									NIL			,;		//05
									NIL			,;		//06
									aRbxFields	,;		//07
									aObjSize[1] ,;		//08
									aRbxAltera	,;		//09
									NIL			,;		//10
									NIL			,;		//11
									NIL			,;		//12
									oDlg		,;		//13
									NIL			,;		//14
									.F.			,;		//15
									.T.			,;		//16
									.F.			,;		//17
									NIL			,;		//18
									NIL			,;		//19
									NIL			,;		//20
									NIL			;		//21
								)
         
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Valor DEFAULT nOpcNewGd  4 - Visualizar					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		nOpcNewGd := 4
 
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto GetDados para o RBX						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		oGdRbx	:= MsNewGetDados():New(	5															,;
										5															,;
										aObjSize[2,3]-aObjSize[2,1]-15								,;
										aObjSize[2,4]-aObjSize[2,2]-5								,;
										nOpcNewGd													,;
										NIL															,;
										NIL															,;
										""															,;
										NIL															,;
										0															,;
										NIL															,; 
										NIL															,;
										NIL															,;
										NIL															,;
										oFolders:aDialogs[01]										,;
										aRbxHeader													,;
										aRbxCols		 							 				 ;
								  )
		//Desativado acoes no objeto da get pois ela e apenas para visualizacao.
		//Procedimento efetuado pois campo da enchoice assumia o valor do mesmo na get quando 
		//este era clicado duas vezes e alterado a aba do folder.
        oGdRbx:LACTIVE	    := .F.
        /*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto GetDados para o RCL						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		oGdRcl	:= MsNewGetDados():New(	5															,;
										5															,;
										aObjSize[2,3]-aObjSize[2,1]-15								,;
										aObjSize[2,4]-aObjSize[2,2]-5								,;
										nOpcNewGd													,;
										NIL															,;
										NIL															,;
										""															,;
										NIL															,;
										0															,;
										NIL															,; 
										NIL															,;
										NIL															,;
										NIL															,;
										oFolders:aDialogs[ 02 ]					   					,;
										aRclHeader													,;
										aRclCols		 							 				 ;
									  )    
	ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit )
End Sequence          
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRestaura os Dados de Entrada								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RestArea( aArea )
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura as Teclas de Atalho                				   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RestKeys( aSvKeys , .T. )
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Ponteiro do Cursor do Mouse                  	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()
Return NIL
/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁOrgm10ClearBrwЁ Autor ЁMarcos Alves       Ё Data Ё12/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁLimpar campos da get dados, caso nao esteja na base  		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁORGM010  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function Orgm10ClearBrw(aHeader,aCols)
Local i,nX
Local cTipo

For nX:=1 to Len(aCols)
	If aCols[nX,(Len(aCols[nX])-1)]<>0
		Exit
	EndIf	

	For i := 1 To Len(aHeader)
		cTipo := aHeader[i,8]
		If cTipo == "C"
			aCols[nX][i] := Space(aHeader[i,4])
		ElseIf cTipo == "N"
			aCols[nX][i] := 0
		ElseIf cTipo == "D"
			aCols[nX][i] := Ctod("")
		ElseIf cTipo == "L"
			aCols[nX][i] := .F.
		Else
			aCols[nX][i] := ""
		EndIf
	Next i
Next nX
Return .T.

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммкмммммммямммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁOrgM010Grava ╨Autor  ЁMarcos Alves     ╨ Data Ё  01/11/07   ╨╠╠
╠╠лммммммммммьмммммммммммммймммммммомммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Gravacao da operacao de movimentacao de departamento 	  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAORG                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Static Function OrgM010Grava()
	Local lRet := .F.
	Local nResp		:= 2
	
	If ( RBT->RBT_TIPOR == "2" )	
		If !( ValidTipPos( RBT->RBT_FILIAL, RBT->RBT_CODPOS ) )
			Return .F.			
		EndIf
	EndIf
	
	If Type("lIntRSP") == "U" 	
		Private lIntRSP	:= GetMv("MV_IORGRSP", NIL, "0") == "1"
	Endif
	
	If lIntRSP

		// Quando o tipo do posto for generico e for alteracao de aumento de quadro, envia direto para o RSP
		If RBT->RBT_TPOSTO == '2' .And. RBT->RBT_TIPOR == "2"
			nResp := 1
		Else
			nResp := Aviso(STR0027,;
							STR0044,;
							{STR0021,STR0022},2,;
							STR0023) //"AtenГЦo"###"Deseja abrir a(s) vaga(s) no mСdulo de Recrutamento e SeleГЦo para o(s) posto(s) aprovado(s)?"###"Sim"###"NЦo"###"Confirma operaГЦo"
		Endif

	Endif
		    
	lRet := OrgXAprova( RBT->RBT_FILIAL, RBT->RBT_CODMOV, M->RBX_CODOPE, M->RBX_QTDOPE, M->RBX_JUSTIF, nResp == 1, , RBT->RBT_DEPTO )
Return lRet

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммкмммммммямммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁOrgm10Saldo  ╨Autor  ЁMarcos Alves     ╨ Data Ё  01/11/07   ╨╠╠
╠╠лммммммммммьмммммммммммммймммммммомммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Calculo de movimentacao remanecente de postos              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAORG                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function Orgm10Saldo(lSoma)
	Local aArea		:= GetArea(Alias())
	Local nFuncQtde	:= 0
	Local bCount	:= {||nFuncQtde+=RBX->RBX_QTDOPE }
	Local bWhile	:= {||xFilial("RBX")+RBT->RBT_DEPTO+RBT->RBT_CODMOV == RBX->RBX_FILIAL+RBX->RBX_DEPTO+RBX->RBX_CODMOV}
	
	RBX->(dbSeek(xFilial("RBX")+RBT->RBT_DEPTO+RBT->RBT_CODMOV, .F.))
	RBX->(dbEval(bCount,,bWhile))
	
	If lSoma
		nFuncQtde:= RBT->RBT_QTDMOV - nFuncQtde
	EndIf
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁRestaura os Dados de Entrada								   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	RestArea( aArea )
Return(nFuncQtde)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁORGA040   ╨Autor  ЁMicrosiga           ╨ Data Ё  09/29/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GA1040TudOk()
Local lRet			:= .T.
If M->RBT_QTDMOV <= 0
	Alert(STR0033)	//"Verifique a quantidade digitada."
 	lRet	:= .f.
Endif

If Type("lIntRSP") == "U" 	
		Private lIntRSP	:= GetMv("MV_IORGRSP", NIL, "0") == "1"
Endif
	
// Verifica se houver integracao entre ORG e RSP o campo RBT_FUNCAO deve ser obrigatorio
If lIntRSP .And. EMPTY(M->RBT_FUNCAO)
	Alert(STR0045 + " " + AllTrim(TITSX3("RBT_FUNCAO")[1]) + " " + STR0046) // "O campo" ### "deverА ser preenchido quando a IntegraГЦo entre os mСdulos SIGAORG e SIGARSP estА ativada."
 	lRet	:= .f.
Endif

Return(lRet)

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Marcos Alves     Ё Data Ё21/11/2006Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁORGM010                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   
Static Function MenuDef()
	Local aRotina := {	{STR0002,	"AxPesqui",		0, 1} 	,;	//STR0002
						{STR0003,	"ORGM10Vis",	0, 2}	,;	//"Visualizar"
						{STR0006,	"ORGM10Inc",	0, 3} 	,;	//"Inclusao"
						{STR0004,	"ORGM10Alt",	0, 4}	,;	//"Alterar"
						{STR0005,	"ORGM10Exc",	0, 5}	,;	//"Excluir"
						{STR0010,	"ORGM10Oper",	0, 4} 	,;	//"Operar"
						{STR0007,	"ORGM10Leg",	0, 6} }		//"Legenda"
Return aRotina

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDeptoIni		 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DEPTO					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DEPTO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/                                                                                                         
Function RbtDeptoIni()
	Local cRet:= RBT->RBT_DEPTO

	If TYPE("INCLUI") == "L" .and. INCLUI             
		If FunName() == "ORGM010"
			cRet:= Replicate(" ", GetSx3Cache("RBT_DEPTO","X3_TAMANHO"))
		Else
			cRet:= SQB->QB_DEPTO
		EndIF
	EndIf
Return cRet

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDtaMovIni	 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DTAMOV					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DTAMOV								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtDtaMovIni()
	Local cRet:= RBT->RBT_DTAMOV

	If TYPE("INCLUI") == "L" .and. INCLUI             
		cRet:= dDataBase
	EndIf
Return cRet

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtFuncIni()	 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_FUNCAO					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_FUNCAO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtFuncIni()
	Local cRet:= RBT->RBT_FUNCAO

	If TYPE("INCLUI") == "L" .and. INCLUI             
		cRet:= ""
	EndIf
Return cRet

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtCargoIni()	 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_CARGO					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_CARGO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtCargoIni()
	Local cRet:= RBT->RBT_CARGO

	If TYPE("INCLUI") == "L" .and. INCLUI             
		cRet:= ""
	EndIf
Return cRet

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtCCIni()		 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_CC						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_CC									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtCCIni()
	Local cRet:= RBT->RBT_CC

	If TYPE("INCLUI") == "L" .and. INCLUI             
		cRet:= ""
	EndIf
Return cRet

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDCCInit		 ЁAutorЁMarcos Alves	  Ё Data Ё24/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DCC						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DCC									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtDCCInit()
	Local cRbtDCCInit	:= ""
	Local nOrder		:= RetOrdem( "CTT" , "CTT_FILIAL+CTT_CUSTO" , .F. )
	Local cRbtCC
	Local lGetDados
	
	If TYPE("INCLUI") == "L" .and. !INCLUI
		lGetDados := IsInGetDados( { "RBT_DCC" , "RBT_CC" } )
		IF ( lGetDados )
			cRbtCC		:= GetMemVar( "RBT_CC" )
			cRbtDCCInit	:= PosAlias( "CTT" , cRbtCC , xFilial( "RBT" ) , "CTT_DESC01" , nOrder , .F. )
		Else
			cRbtDCCInit	:= PosAlias( "CTT" , RBT->RBT_CC , xFilial("RBT") , "CTT_DESC01" , nOrder , .F. )
		EndIF
	EndIf
Return( cRbtDCCInit )           

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDCCBrw		 ЁAutorЁMarcos Alves	  Ё Data Ё24/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Browse para o Campo RBT_DCC		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_INIBRW do campo RBT_DCC									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtDCCBrw()
Return( RbtDCCInit() )


/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDCCInit		 ЁAutorЁMarcos Alves	  Ё Data Ё24/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DCC						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DDEPTO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtDDeptoInit()
	Local cRbtRet	:= ""
	Local nOrder	:= RetOrdem( "SQB" , "QB_FILIAL+QB_DEPTO" , .F. )

	cRbtRet:= VisualInit(	"SQB"		,; 	//Tabela de pesquisa da informacao
				nOrder		,;	//Ordem da tabela de pesquisa
				"RBT_DEPTO",;	//Campo da informacao origem 
				"RBT_DDEPTO",;	//Campo recebimento da informaГЦo
				"QB_DESCRIC")	//Campo de retorno da tabela origem
Return( cRbtRet )         

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDDeptoBrw	 ЁAutorЁMarcos Alves	  Ё Data Ё24/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Browse para o Campo RBT_DDEPTO		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_INIBRW do campo RBT_DDEPTO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtDDeptoBrw()
Return( RbtDDeptoInit() )

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDFuncInit	 ЁAutorЁMarcos Alves	  Ё Data Ё24/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DFUNC						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DFUNC								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtDFuncInit()
Local cRbtRet	:= ""
Local nOrder	:= RetOrdem( "SRJ" , "RJ_FILIAL+RJ_FUNCAO" , .F. )

IF ( IsInGetDados( { "RBT_DFUNC" , "RBT_FUNCAO" } ) )
	cRbtRet:=Posicione("SRJ",nOrder,xFilial("SRJ")+GetMemVar( "RBT_DEPTO" ),"RJ_DESC")
Else
	IF TYPE("INCLUI") == "L" .and. !INCLUI
       cRbtRet := Posicione("SRJ",nOrder,xFilial("SRJ")+RBT->RBT_FUNCAO,"RJ_DESC")
    Else   
       cRbtRet := ""
    EndIf
EndIF
Return( cRbtRet )         

/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDFuncBrw		 ЁAutorЁMarcos Alves	  Ё Data Ё24/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Browse para o Campo RBT_DFUNC		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_INIBRW do campo RBT_DFUNC								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtDFuncBrw()
Return(RbtDFuncInit())
      
/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDCargoInit	 ЁAutorЁMarcos Alves	  Ё Data Ё24/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DCARGO					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DCARGO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbtDCargoInit()
Local cRbtRet	:= ""
Local nOrder	:= RetOrdem( "SQ3" , "Q3_FILIAL+Q3_CARGO" , .F. )

cRbtRet:= VisualInit(	"SQ3"		,; 	//Tabela de pesquisa da informacao
						nOrder		,;	//Ordem da tabela de pesquisa
						"RBT_CARGO"	,;	//Campo da informacao origem 
						"RBT_DCARGO",;	//Campo recebimento da informaГЦo
						"Q3_DESCSUM")	//Campo de retorno da tabela origem
Return( cRbtRet )         
/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDCargoBrw	 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Browse para o Campo RBT_DCARGO		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_INIBRW do campo RBT_DCARGO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtDCargoBrw()
Return(RbtDCargoInit())


/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDProcInit	 ЁAutorЁRogerio Ribeiro	  Ё Data Ё24/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DCARGO					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DCARGO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbtDProcInit()
Local cRbtRet	:= ""
Local nOrder	:= RetOrdem("RCJ", "RCJ_FILIAL+RCJ_CODIGO", .F. )

cRbtRet:= VisualInit(	"RCJ",; 	//Tabela de pesquisa da informacao
						nOrder,;	//Ordem da tabela de pesquisa
						"RBT_PROCES",;	//Campo da informacao origem 
						"RBT_DPROC",;	//Campo recebimento da informaГЦo
						"RCJ_DESCRI")	//Campo de retorno da tabela origem
Return( cRbtRet )         


/*/
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDProcBrw	 ЁAutorЁRogerio Ribeiro	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Browse para o Campo RBT_DCARGO		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_INIBRW do campo RBT_DCARGO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbtDProcBrw()
Return(RbtDProcInit())


/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtDCargoInit	 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DCARGO					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DCARGO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function VisualInit(	cAlias,; 	//Tabela de pesquisa da informacao
				  		nOrder,;	//Ordem da tabela de pesquisa
						cField,;	//Campo da informacao origem 
						cField2,;	//Campo recebimento da informaГЦo
						cFieldRet,;
						cFieldFil)	//Campo de retorno da tabela origem
	Local cReturn	:= ""
	Local cKey		:= &(Subs(cField,1,3)+ "->" + cField)
	Local cFilTmp	:= xFilial(cAlias, IIF(cFieldFil != NIL, &(Subs(cField,1,3)+ "->" + cFieldFil), NIL) )
	Default nOrder:= 1
	
	IF ( IsInGetDados( { cField, cField2} ) ).OR.!Empty(GetMemVar(cField))
		cReturn:=Posicione(cAlias, nOrder, xFilial(cAlias, GetMemVar(cFieldFil) ) + GetMemVar(cField), cFieldRet)
	Else
		IF TYPE("INCLUI") == "L" .and. !INCLUI
          cReturn := Posicione(cAlias, nOrder, cFilTmp + cKey, cFieldRet)
          varinfo('creturn 01->',cReturn)
       Else   
          cReturn := ""
          varinfo('creturn 02->',cReturn)
       EndIf
	EndIF
Return cReturn

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbxDDeptoInit	 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DCARGO					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DCARGO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbxDDeptoInit()
Local cReturn	:= ""
Local nOrder	:= RetOrdem( "SQB" , "QB_FILIAL+QB_DEPTO" , .F. )
Local lInclui	:=INCLUI
INCLUI:=.F.

cReturn:= VisualInit(	"SQB"		,; 	//Tabela de pesquisa da informacao
						nOrder		,;	//Ordem da tabela de pesquisa
						"RBT_DEPTO",;	//Campo da informacao origem 
						"RBX_DDEPTO",;	//Campo recebimento da informaГЦo
						"QB_DESCRIC")	//Campo de retorno da tabela origem
INCLUI:=lInclui
Return( cReturn )

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbxQtdOpeVld     ЁAutorЁMarcos Alves	  Ё Data Ё22/11/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValidacao do Campo RBX_QTDOPE           					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID do campo RBX_QTDOPE								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbxQtdOpeVld()
Local lRet		:= .T.
If (M->RBX_QTDOPE<=0).OR.(M->RBX_QTDOPE>M->RBX_QTDISP)
	Aviso(STR0027,STR0019+AllTrim(Str(M->RBX_QTDISP)),{"Ok"},2,STR0018)//"AtenГЦo"#"Quantidade invalida!!"#"Disponivel "
	lRet:= .F.
EndIf
Return lRet

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbxCodOpeVld     ЁAutorЁMarcos Alves	  Ё Data Ё22/11/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValidacao do Campo RBX_QTDOPE           					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID do campo RBX_QTDOPE								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbxCodOpeVld()
Return NaoVazio() 

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁOrgm10Refresh	 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ёatualiza a getdados, apos novas inclusoes					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁSIGAORG														Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Orgm10Refresh(cAlias,bGet,aHeader,aCols,nUsado,oGd)
Local lLocks	:=.t.
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁLock do Registro do Rbx									   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
IF !( lLocks := WhileNoLock( cAlias , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGet ) )
	Break
EndIF

oGd:aCols	:= aClone( aCols )
oGd:Refresh()
Return NIL

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁOrgM10Confirma   ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValida dados para gravacao, apos botao de OK			    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁSIGAORG														Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function OrgM10Confirma(bGetRbx,aRbxHeader,aRbxCols,nRbxUsado,oGdRbx,;
                        bGetRcl,aRclHeader,aRclCols,nRclUsado,oGdRcl,;
                        aRbxGetHeader)
	Local aBox	:={}
	Local cMsg	:=""
	Local lRet	:=.T.
	Local nResp
	
	SX3->(DbSetOrder(2))
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Verifica Se o Campos Estao Devidamente Preenchidos		   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	lRet:=Obrigatorio(aGets,aTela)
	If lRet
		If Empty(M->RBX_CODOPE)
			SX3->(DbSeek("RBX_CODOPE"))
			Aviso(STR0027,AllTrim(X3Titulo()),{"Ok"},2,STR0020)//"AtenГЦo"#"Campo nЦo preenchido"
			lRet:=.F.
		EndIf
	EndIf
	
	If lRet
		lRet:=RbxQtdOpeVld()
	EndIf
	
	If !lRet
		Return lRet
	EndIf
	
	SX3->(DbSeek("RBX_CODOPE"))
	aBox:=RetSx3Box(AllTrim(X3CBox()),,,1)
	cMsg+=aBox[Val(M->RBX_CODOPE),3]+" "+Alltrim(Str(M->RBX_QTDOPE))+" posto(s)"
	nResp:=Aviso(STR0027,cMsg,{STR0021,STR0022},2,STR0023)//"AtenГЦo"#"Sim"#"NЦo"#"Confirma operaГЦo"
	
	If nResp==1
		MsgRun(STR0024,STR0025,{|lRet| lRet:=OrgM010Grava()})//"Gravando...MovimentaГЦo/postos"#"Aguarde..."
		If lRet
			/*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Atulizacao das getdados									   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			MsgRun(STR0026,STR0025,{|| Orgm10Refresh("RBX",bGetRbx,aRbxHeader,aRbxCols,nRbxUsado,oGdRbx)}) //"Atualizando....MovimentaГЦo"#"Aguarde..."
			MsgRun(STR0028,STR0025,{|| Orgm10Refresh("RCL",bGetRcl,aRclHeader,aRclCols,nRclUsado,oGdRcl)})//"Atualizando....postos"#"Aguarde..."
			If ExistBlock( "ORG10CON" )	
				ExecBlock("ORG10CON",.F.,.F.)     
			Endif
		EndIf
	Else
		lRet:= .F.
	EndIf
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Atualizar o saldo de postos movimentacoes para atualizar	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	Orgm10InitVar(aRbxGetHeader,{"RBX_QTDISP","RBX_CODOPE","RBX_QTDOPE"})
Return lRet

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbxDispInit		 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBX_QTDISP					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBX_QTDISP								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbxDispInit()
Return Orgm10Saldo(.T.)

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁOrgm10InitVar	 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora variaveis de memoria para MSMGET				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBX_QTDISP								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Orgm10InitVar(aHeader,aRbxCps)
	Local aArea		:= GetArea(Alias())
	Local aCols		:= If(aRbxCps	== NIL,{},Array(1,Len(aHeader)))
	Local nRbxUsado	:= Len(aHeader)
	Local nLoop		:= 0
	
	Default aRbxCps	:= NIL
	Default aRbxCps	:= NIL
	
	GdDefault( aRbxCps, "RBX", aHeader , aCols , 1)
	
	If aRbxCps	== NIL
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Cria as Variaveis de Memoria e Carrega os Dados Conforme o arЁ
		Ё quivo														   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		For nLoop := 1 To nRbxUsado
			_SetOwnerPrvt(aHeader[nLoop, 02], SetMemVar(aHeader[nLoop, 02], aCols[01, nLoop], .T.))
		Next nLoop
	Else
		For nLoop:=1 to Len(aRbxCps)
			//criar variavel private no environment anterior
			_SetOwnerPrvt(aRbxCps[nLoop], SetMemVar(aRbxCps[nLoop], GdFieldGet(aRbxCps[nLoop], 1 , .F. , aHeader , aCols ), .T.))
		Next nLoop
	EndIf
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁRestaura os Dados de Entrada								   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	RestArea( aArea )
Return aCols

Function ORGM10Leg(cAlias,nReg,nOpc)
	ORGM10ShowLegend("RBT", "L")
Return

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁORGM10Leg	 ЁAutorЁMarcos Alves          Ё Data Ё21/11/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao legenda (RBT, RBX, RCL)                              Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ cTab - Tabela da Leganda ("RBT", "RBX", "RCL")				Ё
Ё		   Ё cTipo - "L": Legenda, "G": Getdados 						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁORGM010								                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function ORGM10ShowLegend(cTab, cTipo)
	Local aCores	:= {}  
	Local cCor		:= "BR_BRANCO"
	Local nPosCor	:= 1
	Local aSvKeys 	:= GetKeys()
	Local nRclOrd
	Default cTipo	:= "L"
	
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁLegenda da MsBrowse (aRotina)								   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	If cTab=="RBT"
		aadd(aCores,{"BR_VERMELHO"	, OemToAnsi(STR0011)})		//"Baixados"
		aadd(aCores,{"BR_AMARELO"	, OemToAnsi(STR0012)})		//"Pendencia Parcial"
		aadd(aCores,{"BR_VERDE"	, OemToAnsi(STR0013)}) 		//"Pendencia Total"
		cMsgLeg:=cCadastro
	ElseIf cTab=="RBX"
		aadd(aCores,{"BR_LARANJA"	, OemToAnsi(STR0029) })		//"Aprovado"
		aadd(aCores,{"BR_PRETO"	, OemToAnsi(STR0031) })		//"Reprovado"
		aadd(aCores,{"BR_BRANCO"	, OemToAnsi(STR0032) })		//"Congelado"
		cMsgLeg:=STR0034 //"OperaГУes de departamentos"
	ElseIf cTab=="RCL"
		aadd(aCores,{"BR_LARANJA"	, STR0035})		//"Postos da movimentaГЦo"
		aadd(aCores,{"BR_AZUL"		, STR0036})		//"Outras movimentaГУes"
		cMsgLeg:=STR0037 //"Origem dos postos"
	EndIf
	
	Begin Sequence
		If cTipo == "L"
			BrwLegenda(cMsgLeg, STR0007, aCores) //Legenda
		Else
		    If cTab == "RBX" 						//Coluna "COLBMP" de NewGetdados do RBX
		      nPosCor:= Val(RBX->RBX_CODOPE)
			ElseIf cTab == "RCL"					//Coluna "COLBMP" de NewGetdados do RCL
				nRclOrd	:= RetOrdem("RBU" ,"RBU_FILIAL+RBU_ORIGEM+RBU_DEPTO+RBU_POSTO+DTOS(RBU_DTAMOV)")				
				RBU->(dbSetOrder(nRclOrd))
				
				If RBU->(dbSeek(xFilial("RBU")+RBT->RBT_CODMOV+RCL->RCL_DEPTO+RCL->RCL_POSTO))
					nPosCor	:=1					// Postos gerados desta movimentaГЦo 
				Else
					nPosCor	:=2					// Postos gerados de outras movimentaГУes 
				EndIf	
			EndIf
			
			cCor:= aCores[nPosCor, 1]	
		EndIf
	End Sequence
	
	RestKeys( aSvKeys , .T. )
Return cCor

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtInitDJustif	 ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBT_DJUST					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBT_DJUST								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbtInitDJustif()
Local cReturn	:= ""
IF ( IsInGetDados( { "RBT_JUSTIF"} ) ).OR.!Empty(GetMemVar("RBT_JUSTIF"))
	cReturn:=Posicione('SX5',1,xFilial('SX5')+'BX'+GetMemVar("RBT_JUSTIF"),'X5_DESCRI')
Else
	IF TYPE("INCLUI") == "L" .and. !INCLUI
       cReturn := cReturn:=Posicione('SX5',1,xFilial('SX5')+'BX'+RBT->RBT_JUSTIF,'X5_DESCRI')
    Else   
       cReturn := ""
    EndIf
EndIF                                                                                1
Return( cReturn )         

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbtBrwDJustif    ЁAutorЁMarcos Alves	  Ё Data Ё26/11/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Browse para o Campo RBT_DJUST		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_INIBRW do campo RBT_DJUST								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbtBrwDJustif()
Return Posicione('SX5',1,xFilial('SX5')+'BX'+RBT->RBT_JUSTIF,'X5_DESCRI')

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbxInitDJustif   ЁAutorЁMarcos Alves	  Ё Data Ё26/10/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Campo RBX_DJUST					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO do campo RBX_DJUST								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbxInitDJustif()
Local cReturn	:= ""
IF ( IsInGetDados( { "RBX_JUSTIF"} ) ).OR.!Empty(GetMemVar("RBX_JUSTIF"))
	cReturn:=Posicione('SX5',1,xFilial('SX5')+'JP'+GetMemVar("RBX_JUSTIF"),'X5_DESCRI')
Else
	IF TYPE("INCLUI") == "L" .and. !INCLUI
       cReturn:=Posicione('SX5',1,xFilial('SX5')+'JP'+RBX->RBX_JUSTIF,'X5_DESCRI')
    Else   
       cReturn := ""
    EndIf
EndIF                                                                                1
Return( cReturn )         
/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbxBrwDJustif    ЁAutorЁMarcos Alves	  Ё Data Ё26/11/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Browse para o Campo RBX_DJUST		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_INIBRW do campo RBX_DJUST								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbxBrwDJustif()
Return Posicione('SX5',1,xFilial('SX5')+'JP'+RBX->RBX_JUSTIF,'X5_DESCRI')

/*
зддддддддддбдддддддддддддддддбдддддбддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbxTPostoIni     ЁAutorЁMarcos Alves	  Ё Data Ё26/11/2007Ё
цддддддддддедддддддддддддддддадддддаддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializadora Padrao do Browse para o Campo RBX_TPOSTO 	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_INIBRW do campo RBX_TPOSTO								Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RbxTPostoIni()
Return RBT->RBT_TPOSTO


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁORGA040   ╨Autor  ЁMicrosiga           ╨ Data Ё  09/26/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function FCADRBTA10()
	Local nReg			:= 0
	Local nOpc			:= 3
	Local lIncAnt		:= INCLUI
	Local lAprova		:= SuperGetMV("MV_APRPOST",NIL,"S") == "S" //Se utiliza rotina de aprovaГЦo de posto
	Local lRet			:= .F.
	Local nRet			:= 0
	Local nResp			:= 0
	
	Private cCadastro 	:= STR0001	//"ManutenГЦo"
	Private aRotina 	:= MenuDef()

	DEFAULT aAcho := GetRBTFields(.T.)
	DEFAULT aAlter := GetRBTFields(.F.)
	DEFAULT lIncPosto := ExistBlock( "ORGMSOL1" )

	If Type("lIntRSP") == "U" 	
		Private lIntRSP	:= GetMv("MV_IORGRSP", NIL, "0") == "1"
	Endif
		
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Ponto de Entrada 								               Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	bBlkInc := { || If( lIncPosto, ExecBlock("ORGMSOL1",.F.,.F., { RBT->RBT_FILIAL, RBT->RBT_CODMOV } ), .T. ) }	

	dbSelectArea("RBT")
	dbSetOrder(1)
	
	If Eof()
		nReg:= 1
	Endif
	
	INCLUI	:= .T.
	
	nRet := AxInclui("RBT", nReg, nOpc, aAcho, NIL, aAlter, "GA1040TudOk()", NIL, NIL, NIL, {{||.T.},{||.T.},{||.T.},bBlkInc }, NIL, NIL, .T.)	
	INCLUI	:= lIncAnt
	
	If !lAprova .and. nRet == 1
	
		If lIntRSP
	
			// Quando o tipo do posto for generico e for alteracao de aumento de quadro, envia direto para o RSP
			If RBT->RBT_TPOSTO == '2' .And. RBT->RBT_TIPOR == "2"
				nResp := 1
			Else
				nResp := Aviso(STR0027,;
								STR0044,;
								{STR0021,STR0022},2,;
								STR0023) //"AtenГЦo"###"Deseja abrir a(s) vaga(s) no mСdulo de Recrutamento e SeleГЦo para o(s) posto(s) aprovado(s)?"###"Sim"###"NЦo"###"Confirma operaГЦo"
			EndIf
	
		EndIf
			    
		lRet:=OrgXAprova( RBT->RBT_FILIAL, RBT->RBT_CODMOV, "1", RBT->RBT_QTDMOV, "01", nResp == 1, , RBT->RBT_DEPTO )
	
		If lRet
			aDados := {}
			If ExistBlock( "ORG10CON" )	
				ExecBlock("ORG10CON",.F.,.F.)     
			EndIf
		EndIf
	EndIf
	
Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁORGM010   ╨Autor  ЁMicrosiga           ╨ Data Ё  09/25/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function AxAlM010()
	Local aIndexRBT		:= {}
	Local cFilterRBT	:= ChkRh("ORGM010","RBT","1")
	Local cSetFilter	:= ""
	Private cCadastro 	:= STR0001	//"ManutenГЦo"
	Private aRotina := MenuDef()	
	Private cDelFunc 	:= ".T."	
	Private oObjMBrw := GetObjBrow()
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSelectArea("RBT")
	
	cSetFilter:= cFilterRBT + IF(!Empty(cFilterRBT), " .AND. ", "") + "RTRIM(RBT_DEPTO) = '" + RTRIM(SQB->QB_DEPTO) + "'"
	bFiltraBrw := { || FilBrowse("RBT", @aIndexRBT, @cSetFilter) }
	Eval( bFiltraBrw )
	
	RBT->( dbGoTop() )
	MBrowse( 6,1,22,75,"RBT",,,,,, fCriaCor())

	SET FILTER TO
Return


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁORGM010   ╨Autor  ЁMicrosiga           ╨ Data Ё  09/26/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function fCriaCor()

	Local aCores	:=	{{"RBT->RBT_STATUS  = '1'", 'BR_VERMELHO'},;	// baixados
						 {"RBT->RBT_STATUS  = '2'", 'BR_AMARELO'},;	// Pendente parcial
						 {"RBT->RBT_STATUS  = '3'", 'BR_VERDE'}}  	// Pendente total

Return(aCores)

Static Function GetRBTFields(lCodigo)
	Local aRbtHeader 	:= {}
	Local aReturn		:= {}
	Local aNoFields		:= {"RBT_FILIAL","RBT_STATUS","RBT_RESPON"}
	
	
	If !lCodigo
		AAdd(aNoFields, "RBT_CODMOV")
	EndIf
	
      
	aRbtHeader 			:= GdMontaHeader(	NIL				,;	//01 -> Por Referencia contera o numero de campos em Uso
												NIL				,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
												NIL				,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
												"RBT"			,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
												aNoFields	,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
												.F.				,;	//06 -> Opcional, Carregar Todos os Campos
												.F.			 	,;	//07 -> Nao Carrega os Campos Virtuais
												.F.				,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
												NIL				,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
												.T.				,;	//10 -> Verifica se Deve Checar se o campo eh usado
												.T.				,;	//11 -> Verifica se Deve Checar o nivel do usuario
												.F.				 ;	//12 -> Utiliza Numeracao na GhostCol
							  	 			)
		
	Aeval(aRbtHeader, {|X| AADD(aReturn,x[2])})

Return aReturn


// Inicializador padrЦo do campo RBT_DESLOC
Function RBTDLocInit()
	Local cRbtLRet	:= " "
	Local nOrder	:= RetOrdem( "RGC" , "RGC_FILIAL+RGC_KEYLOC" , .F. )
	
	cRbtLRet := VisualInit(	"RGC"			,; 	//Tabela de pesquisa da informacao
							nOrder			,;	//Ordem da tabela de pesquisa
							"RBT_LOCPAG"	,;	//Campo da informacao origem 
							"RBT_DESLOC"	,;	//Campo recebimento da informaГЦo
							"RGC_DESLOC"	)	//Campo de retorno da tabela origem						
Return cRbtLRet

Function RBTDLocBrw()
Return RBTDLocInit()

/*/
зддддддддддбдддддддддддбдддддбдддддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o    ЁValidTipPosЁAutorЁIgor Franzoi	           	 ЁDataЁ03/12/2008Ё
цддддддддддедддддддддддадддддадддддддддддддддддддддддддддаддддадддддддддд╢
ЁDescri┤┘o ЁPesquisa o campo no SX3									     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁORGA030				     				             	   	 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function ValidTipPos( cFilRCL, cCodPos )

Local lRet	:= .T.

Local aArea := GetArea()

dbSelectArea("RCL")
dbSetOrder(RetOrder("RCL","RCL_FILIAL+RCL_POSTO"))
RCL->(dbSeek(cFilRCL+cCodPos))

If RCL->RCL_TPOSTO == "1"
	If !MsgYesNo( OemToAnsi(STR0042)+CRLF+OemToAnsi(STR0043), OemToAnsi(STR0027) ) //"O Posto Origem И Individual, apСs a aprovaГЦo ele se tornarА GenИrico!""Deseja continuar?"-"Atencion"
		lRet := .F.
	EndIf
EndIf

Restarea(aArea)

Return ( lRet )
         
/*/
зддддддддддбддддддддддддддбдддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁORGM10FunValidЁAutorЁIP - RH Inovacao     Ё Data Ё07/02/2012Ё
цддддддддддеддддддддддддддадддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValida o codigo da funcao caso houver integracao com RSP    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ Nenhum														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁORGM010								                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function ORGM10FunValid()
Local lRet 		:= .F.
Local lIntRSP	:= GetMv("MV_IORGRSP", NIL, "0") == "1"

If !lIntRSP
	If Vazio() .Or. ( NaoVazio() .And. ExistCpo('SRJ') ) 
		lRet := .T.
	EndIf
Else
	If ( NaoVazio() .And. ExistCpo('SRJ') ) 
		lRet := .T.
	Endif
Endif

Return lRet


/*/{Protheus.doc} ORGM10DepValid
	Verify that the current "Role"(Establish position) belongs to the selected "Department"
	@type  Function
	@author Anastasiya.kulagina
	@since 27/04/2018
	@version 1.0
/*/
Function ORGM10DepValid()
Local lRet 		:= .F.
Local cCodeDep
IF cPaisLoc == 'RUS' .AND. !EMPTY(GetMemVar("RBT_FUNCAO"))
	cCodeDep := Posicione("SRJ",1,xFilial("SRJ") + M->RBT_FUNCAO ,"RJ_DEPTO")
	IF cCodeDep == M->RBT_DEPTO
		lRet := .T.
	ELSE 
		ALERT(STR0048) // "The position does not correspond to the Department"
	ENDIF
ELSE 
	lRet := .T.
ENDIF

Return lRet


/*/{Protheus.doc} fAssocPos
	Returns the Position code of the current Role(Establish position)
	@type  Function
	@author Anastasiya.Kulagina
	@since 27/04/2018
	@version 1.0
	@param cPosition, Caracter, Position code
	@return cPosition, Caracter, Position code
/*/
Function  fAssocPos(cPosition) 
RETURN Posicione("SRJ",1,xFilial("SRJ") + cPosition,"RJ_CARGO")


 /*/{Protheus.doc} Orgm10SetFil
	The function generates a filter for the standard SRJRUS request by the value of the selected Department
	@type  Function
	@author Anastasiya.Kulagina
	@since 27/04/2018
	@version 1.0
	/*/
Function Orgm10SetFil()
Local cFilter := ""

	If !Empty(M->RBT_DEPTO)
 		
		 cFilter := "SRJ->RJ_DEPTO == '" + M->RBT_DEPTO + "'"
	EndIf

	cFilter := "@#" + cFilter + "@#"

Return(cFilter)
