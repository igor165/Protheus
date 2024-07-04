#include "PLSMGER.CH"
#include "PROTHEUS.CH"

#define __aCdCri032 {"540","Erro controlado SIGAPLS."}
#define __aCdCri129 {"900","Usuario de intercambio ja cadastrado como eventual."}  
#define __aCdCri130 {"901","Usuario de intercambio ja cadastrado como repasse."}  
#define __aCdCri131 {"902","Usuario de intercambio ja ligado a operadora padrao."}  
#define __aCdCri132 {"903","Subcontrato cadastrado para intercambio invalido."}
#define __aCdCri133 {"904","Operadora do usuario de intercambio possui mesmo codigo da operadora padrao."}
#define __aCdCri134 {"905","Tabela de tipos de intercambio invalida ou nao possui registros."}

#define cNotContr "..."
#define cNotVerao "..."
#define cNotSubco "..."
#define cBQCCodA "..."

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA235 Ё Autor Ё Tulio Cesar          Ё Data Ё 16.01.2003 Ё╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Inclusao de Usuarios do Intercambio                        Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Especifico Clientes Unimeds                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA235(lMsgNovaMat,cMatrNova,lInterGen,lIncAuto,cNomUsr,dDatNasUsr,lRPC,cSexo,lIncWeb,lChkCon,lSolTISSOn)
Local I__f := 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL aArea     := GetArea()
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL aButtons  := {}                             
LOCAL bOK       := {|| nOpca := 1,If(Obrigatorio(oEncInt:aGets,oEncInt:aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel   := {|| oDlg:End() }
LOCAL oEncInt
LOCAL cMatric
LOCAL lIncluido := .F.
LOCAL aOldTela  := If(Type('aTela')=="A",aClone(aTela),{})
LOCAL aOldGets  := If(Type('aGets')=="A",aClone(aGets),{})
LOCAL dDatNas 
LOCAL aRet      := {}
LOCAL aRetUsr	:= {}
Local nPos
LOCAL nH
LOCAL cCodPla
LOCAL cVersao
LOCAL aCodCri   := {}
LOCAL cTitular 	:= SuperGetMv("MV_PLCDTIT")
LOCAL cGrauPar	:= SuperGetMv("MV_PLCDTGP")
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local lIncSU5   := SuperGetMv("MV_PLSCONT") 
LOCAL aOldRotina:= If(Type('aRotina')=="A",aClone(aRotina),{})
LOCAL nRecBT6   := 0
PRIVATE aTELA[0][0]                                                          
PRIVATE aGETS[0]
PRIVATE cCadastro := "Inclusao de Usuarios do Intercambio - "
PRIVATE aRotina   := MenuDef()
DEFAULT lMsgNovaMat := .T.
DEFAULT lInterGen   := .F.
DEFAULT lIncAuto    := .F.
DEFAULT cNomUsr     := CriaVar("BER_NOME")
DEFAULT dDatNasUsr  := ctod("")
DEFAULT lRPC		:= .F.
DEFAULT cSexo		:= ""
DEFAULT lIncWeb   	:= .F.
DEFAULT lChkCon		:= .F.
DEFAULT lSolTISSOn  := .F.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da enchoice...                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Copy "BER" To Memory Blank   

M->BER_NOME := cNomUsr

If ! lMsgNovaMat                                                             
	M->BER_USUARI := cMatrNova             
   
   If lIncWeb
	   aRetUsr := PLSA235USR(cMatrNova,lInterGen,lRPC,lIncWeb,lChkCon)
	   If !aRetUsr[1] 
	      Return( aRetUsr )
	   Endif   
   Else 
	   If ! PLSA235USR(cMatrNova,lInterGen,lRPC,,lChkCon,aCodCri)
	      Return({.F.,aCodCri})
	   Endif   
   EndIf   
   
Endif   

If ! Empty(M->BER_CODPRO)
   cCodPla := M->BER_CODPRO
   cVersao := M->BER_VERPRO
Else
   cCodPla := GetNewPar("MV_PLSPLPE","0001")
   cVersao := GetNewPar("MV_PLSVRPE","001")
Endif   

BT6->(DbSetOrder(1))
//Procura direto considerando o produto...
If ! BT6->(MsSeek(xFilial("BT6")+M->BER_CODINT+M->BER_CODEMP+M->BER_CONEMP+M->BER_VERCON+M->BER_SUBCON+M->BER_VERSUB+cCodPla+cVersao))
   //se nao achar procura sem considerar o produto para pegar o primeiro...
   If ! BT6->(MsSeek(xFilial("BT6")+M->BER_CODINT+M->BER_CODEMP+M->BER_CONEMP+M->BER_VERCON+M->BER_SUBCON+M->BER_VERSUB))
      PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2])
      aadd(aCodCri,{__aCdCri032[1],"Subcontrato X produto de intercambio (BT6) nao possui produto vinculado corretamente ao que esta sendo incluido","",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})
      aadd(aCodCri,{__aCdCri032[1],"Dados do subcontrato ["+M->BER_CODINT+M->BER_CODEMP+M->BER_CONEMP+M->BER_VERCON+M->BER_SUBCON+M->BER_VERSUB+"]","",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})   
      aadd(aCodCri,{__aCdCri032[1],"Dados do Plano e Versao ["+cCodPla+cVersao+"]","",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})   
      aadd(aCodCri,{__aCdCri032[1],"Matricula enviada ["+cMatrNova+"]","",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})      
      aadd(aCodCri,{__aCdCri032[1],"Nome usuario ["+cNomUsr+"]","",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})      
      aadd(aCodCri,{__aCdCri032[1],"Verifique o conteudo dos parametros MV_PLSPLPE e MV_PLSVRPE","",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})      

      Return({.F.,aCodCri})
   Else
   		cCodPla := BT6->BT6_CODPRO
	    cVersao := BT6->BT6_VERSAO   
   
	   	While !BT6->(Eof()) .and. ((xFilial("BT6")+M->BER_CODINT+M->BER_CODEMP+M->BER_CONEMP+M->BER_VERCON+M->BER_SUBCON+M->BER_VERSUB)== BT6->(BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB))
	      cCodPla := BT6->BT6_CODPRO
	      cVersao := BT6->BT6_VERSAO
	      nRecBT6 := BT6->(Recno())//Marca recno para posicionar posteriormente
	      BT6->(DbSkip())  
	   	Enddo
   Endif    
Endif   

If nRecBT6 > 0  //Se 'rodou' BT6 posiciona no ultimo
	BT6->(DbGoTo(nRecBT6))
EndIf                     

BI3->(DbSetOrder(1))
If ! AllTrim(BT6->BT6_MODPAG) $ "1,2,9"
   PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2])
   aadd(aCodCri,{__aCdCri032[1],"Subcontrato x produto de intercambio campo BT6_MODPAG 'Mod.Cobr.' invalido.","",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})
   Return({.F.,aCodCri})
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de Entrada...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PL235INC")
	aRet := ExecBlock("PL235INC",.F.,.F.)
	If  len(aRet) > 0
		For nPos := 1 to len(aRet)
        	If  ValType(&("M->" + alltrim(aRet[nPos,1]))) <> "U"
		    	&("M->" + alltrim(aRet[nPos,1])) := aRet[nPos,2]
		    Endif
		Next
	Endif
Endif   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! lIncAuto
   aSize := MsAdvSize()
   aObjects := {}       
   AAdd( aObjects, { 1,  1, .T., .T., .F. } )
   aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
   aPosObj := MsObjSize( aInfo, aObjects )
   
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

   lRefresh := .F.    
   oEncInt  := BER->(MSMGET():New("BER",0,K_Incluir,,,,,aPosObj[1],,,,,,oDlg,,,.F.))
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Ativa Dialog...                                                          Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)
Else
   nOpca       := K_OK
Endif   
   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia processo de gravacao                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca = K_OK      
    nH         := PLSAbreSem("PLS235GR.SMF")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicia Transacao...                                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Begin Transaction
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se a familia se ja existe a familia...                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA3->(DbSetOrder(4))
	If Empty(M->BER_USUARI) .Or. ! BA3->(MsSeek(xFilial("BA3")+AllTrim(M->BER_USUARI))) .Or. Len(AllTrim(M->BER_USUARI)) > 17
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se nao existir inclui...                                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cMatric := PLPROXMAT(M->BER_CODINT,M->BER_CODEMP)
		
		BA3->(RecLock("BA3",.T.))
		BA3->BA3_FILIAL := xFilial("BA3")
		BA3->BA3_CODINT := M->BER_CODINT
		BA3->BA3_CODEMP := M->BER_CODEMP
		BA3->BA3_CONEMP := M->BER_CONEMP
		BA3->BA3_VERCON := M->BER_VERCON
		BA3->BA3_SUBCON := M->BER_SUBCON
		BA3->BA3_VERSUB := M->BER_VERSUB
		BA3->BA3_ROTINA := "PLSPORFAI"
		BA3->BA3_MATRIC := cMatric
		BA3->BA3_MATANT := M->BER_USUARI
		BA3->BA3_HORACN := StrTran(SubStr(Time(),1,5),":","")
		BA3->BA3_COBNIV := "0"
		BA3->BA3_VENCTO := 0
		BA3->BA3_DATBAS := Iif(!Empty(M->BER_DATCON),M->BER_DATCON,dDataBase)
		BA3->BA3_DATCIV := Iif(!Empty(M->BER_DATCON),M->BER_DATCON,dDataBase)
		BA3->BA3_TIPOUS := "2"
		BA3->BA3_USUOPE := BA3->(RETCODUSR())
	    BA3->BA3_GRPCOB := Posicione('BQC',1,xFilial('BQC')+M->BER_CODINT+M->BER_CODEMP+M->BER_CONEMP+M->BER_VERCON+M->BER_SUBCON+M->BER_VERSUB,'BQC_GRPCOB') 
	    BA3->BA3_CODPLA := If(Empty(M->BER_CODPRO),cCodPla,M->BER_CODPRO)
		BA3->BA3_VERSAO := If(Empty(M->BER_VERPRO),cVersao,M->BER_VERPRO)
        BA3->BA3_TIPCON := BT6->BT6_TIPCON
        BA3->BA3_SEGPLA := BI3->BI3_CODSEG
        BA3->BA3_MODPAG := BT6->BT6_MODPAG
        BA3->BA3_APLEI  := BT6->BT6_APOSRG
        BA3->BA3_ABRANG := BT6->BT6_ABRANG
        BA3->BA3_CODACO := BT6->BT6_CODACO
		
		BA3->BA3_FORPAG := GetNewPar("MV_PLSFCPE","101")
		BA3->BA3_DATCON := Date()
		BA3->BA3_HORCON := StrTran(SubStr(Time(),1,5),":","")
				
		BA3->(MsUnLock())
	Else
		cMatric := BA3->BA3_MATRIC
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Agora inclui o usuario...                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lIncluido := .T.
	
	If Empty(dDatNasUsr)
		dDatNas := M->BER_DATNAS
	Else
		dDatNas :=dDatNasUsr
	Endif
	cSeq := xLSTipReg(M->BER_CODINT,M->BER_CODEMP,cMatric,Iif(!Empty(M->BER_GRAUPA),M->BER_GRAUPA,cGrauPar),Iif(!Empty(M->BER_TIPUSU),M->BER_TIPUSU,cTitular))[1]	
	
	BA1->(RecLock("BA1",.T.))
	BA1->BA1_FILIAL := xFilial("BA1")
	BA1->BA1_CODINT := M->BER_CODINT
	BA1->BA1_CODEMP := M->BER_CODEMP
	BA1->BA1_MATRIC := cMatric
	BA1->BA1_CONEMP := M->BER_CONEMP
	BA1->BA1_VERCON := M->BER_VERCON
	BA1->BA1_SUBCON := M->BER_SUBCON
	BA1->BA1_VERSUB := M->BER_VERSUB
	BA1->BA1_IMAGE  := "ENABLE"
	//antes aqui usava-se o parametro GETMV("MV_PLCDTGP"), mas este parametro define o grau de parentesco do titular o nao o tipReg do tirular
	//para o titular em 99,99999 dos casos eh sempre 00
	BA1->BA1_TIPREG := cSeq
	BA1->BA1_DIGITO := IIF(FindFunction("StrTPLS"),Modulo11(StrTPLS(M->BER_CODINT+M->BER_CODEMP+cMatric+cSeq)),Modulo11(M->BER_CODINT+M->BER_CODEMP+cMatric+cSeq))
	BA1->BA1_NOMUSR := M->BER_NOME
	BA1->BA1_TIPUSU := Iif(!Empty(M->BER_TIPUSU),M->BER_TIPUSU,cTitular)
	BA1->BA1_GRAUPA := Iif(!Empty(M->BER_GRAUPA),M->BER_GRAUPA,cGrauPar)
	If BA1->(FieldPos("BA1_ENDCLI")) > 0
		BA1->BA1_ENDCLI := "0"
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Nao emitir carteirinha para usuario de intercambio						 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BA1->(FieldPos("BA1_EMICAR")) > 0
   	   BA1->BA1_EMICAR := "0"
   	Endif   
   	If Empty(cSexo)
		BA1->BA1_SEXO   := Iif(!Empty(M->BER_SEXO), M->BER_SEXO, GetNewPar("MV_PLSINSE",'1') )
	Else 
		BA1->BA1_SEXO   := cSexo
	EndIf	
	If BER->( FieldPos("BA1_LOCSIB") ) > 0
	   BA1->BA1_LOCSIB := '0'    //Nao enviado
	EndIf   
	
	If Type("M->BER_TELEFO") == "C"
   	   BA1->BA1_TELEFO := M->BER_TELEFO
   	Endif   
	
	BA1->BA1_MATEMP := IF(BER->(FieldPos("BER_MATEMP"))>0,M->BER_MATEMP,"")
	BA1->BA1_MATANT := M->BER_USUARI
	BA1->BA1_ESTCIV := Iif(!Empty(M->BER_ESTCIV), M->BER_ESTCIV, 'S')
	BA1->BA1_CPFUSR := M->BER_CPF
	BA1->BA1_DRGUSR := M->BER_IDENT
	BA1->BA1_DATINC := Iif(!Empty(M->BER_DATINC), M->BER_DATINC, dDataBase)
	BA1->BA1_DATNAS := Iif(!Empty(dDatNas), dDatNas, dDataBase)
	iF !lSolTISSOn
		BA1->BA1_DATCAR := Iif(!Empty(M->BER_DATINC), M->BER_DATINC, dDataBase)
	EndIf	
	BA1->BA1_CBTXAD := "1"
	BA1->BA1_OPEORI := M->BER_OPEORI
	BA1->BA1_OPEDES := M->BER_OPEORI
	BA1->BA1_OPERES := M->BER_OPEORI
	BA1->BA1_LOCATE := "2"
	BA1->BA1_LOCCOB := "2"
	BA1->BA1_LOCEMI := "2"
	BA1->BA1_LOCANS := "2"
	BA1->BA1_INFANS := "0" // nao envia para ANS
	BA1->BA1_INFSIB := "0" // nao envia para SIB
	If BER->( FieldPos("BER_NREDUZ") ) > 0
		BA1->BA1_NREDUZ := M->BER_NREDUZ
	Endif
	If BER->( FieldPos("BER_NOMTIT") ) > 0 .And. BA1->( FieldPos("BA1_NOMTIT") ) > 0
		BA1->BA1_NOMTIT := M->BER_NOMTIT
	Endif

	BA1->BA1_CODPLA := Iif(Empty(M->BER_CODPRO),cCodPla,M->BER_CODPRO)
	BA1->BA1_VERSAO := iif(Empty(M->BER_VERPRO),cVersao,M->BER_VERPRO)

	BA1->BA1_MAE := CriaVar("BA1_MAE")                  
	
	If BA1->(FieldPos("BA1_TIPDOC")) > 0 .And. BER->(FieldPos("BER_TDOC")) > 0 .And. Type("M->BER_TDOC") == "C"
	   BA1->BA1_TIPDOC := M->BER_TDOC
	Endif

	If BA1->(FieldPos("BA1_DRGUSR")) > 0 .And. BER->(FieldPos("BER_DOC")) > 0 .And. Type("M->BER_DOC") == "C"
	   BA1->BA1_DRGUSR := M->BER_DOC
	Endif
	
	BA1->(MsUnLock())
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Esta funcao cria um contato na SU5, com informaГУes da BA1               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lIncSU5 .AND. !Empty(M->BER_EMAIL)
		PLSINCLSU5( BA1->BA1_NOMUSR, M->BER_EMAIL ) 	
	Endif
			
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Esta funcao analise a criacao de uma nova vida ou nao...                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLSA766ANV(nil, !lIncAuto)                                      
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava no usuario a vida criada ou a ja existente...                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA1->(RecLock("BA1",.F.))
	BA1->BA1_MATVID := BTS->BTS_MATVID
	BA1->(MsUnLock())
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gravar a matricula e o tipo de registro no usuario de intercambio!       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	M->BER_MATRIC := cMatric
	M->BER_TIPREG := GETMV("MV_PLCDTGP")
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inclui no arquivo de movimento...                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BER->(PLUPTENC("BER",K_Incluir))

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ponto de entrada apos a gravacao das tabelas                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  ExistBlock("PL235FIM")
		ExecBlock("PL235FIM",.F.,.F.)
	Endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Finaliza Transacao...                                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	End Transaction
	
	PLSFechaSem(nH,"PLS235GR.SMF")               

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Exibe mensagem informativa...                                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lMsgNovaMat .And. ! lIncAuto
		MsgInfo("O usuario foi criado na base sob a matricula  :"+BA3->(BA3_CODINT+"."+BA3_CODEMP+"."+BA3_MATRIC))
	Endif
Else
    lIncluido := .F. 
Endif

aTela := aClone(aOldTela)
aGets := aClone(aOldGets)

aRotina := aClone(aOldRotina)                                                          

RestArea(aArea)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return({lIncluido,If(lIncluido,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),{})})
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA235USR Ё Autor Ё Tulio Cesar         Ё Data Ё 17.01.03 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Valida um usuario de intercambio eventual                  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA235Usr(cMatrUsr,lInterGen,lRPC,lIncWeb,lChkCon,aRet)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da Rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL aDadosUsr
LOCAL lRet     := .F.        
LOCAL cTexto   := ""
LOCAL cCodErro := ""                   
LOCAL cCodOpe
PRIVATE cCadastro 	:= "Usuario"
DEFAULT lInterGen 	:= .F.                    
DEFAULT lIncWeb 	:= .F.
DEFAULT lChkCon     := .F.
DEFAULT aRet	   := {}

If !lIncWeb
	If ! lInterGen .And. Subs(cMatrUsr,1,ntCodOpe) == PLSINTPAD() .And. Len(cMatrUsr) == 17
	   
	   PLSPOSGLO(PLSINTPAD(),__aCdCri133[1],__aCdCri133[2],nil,'1',"2")
	   aadd(aRet,{__aCdCri133[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})	

	   Return(lRet)
	Endif   
	
	If ! lInterGen .And. Subs(cMatrUsr,1,3) == Subs(PLSINTPAD(),2,3) .And. Len(cMatrUsr) == 16
	   
	   PLSPOSGLO(PLSINTPAD(),__aCdCri133[1],__aCdCri133[2],nil,'1',"2")
	   aadd(aRet,{__aCdCri133[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})	

	   Return(lRet)
	Endif   
	
	If ! lInterGen .And. Len(cMatrUsr) == 16
	   cMatrUsr := IIF(FindFunction("StrTPLS"),cMatrUsr+Modulo11(StrTPLS(cMatrUsr)),cMatrUsr+Modulo11(cMatrUsr))
	Endif
EndIf
If ! lInterGen
	aDadosUsr := PLSUSRIEVE(cMatrUsr,"1",dDataBase)
	
	If      aDadosUsr[1] == "0"
		
		If      Val(aDadosUsr[9]) == 1
			cCodErro := __aCdCri129[1]
			cTexto   := __aCdCri129[2]
		ElseIf  Val(aDadosUsr[9]) == 2
			cCodErro := __aCdCri130[1]
			cTexto   := __aCdCri130[2]
		ElseIf  Val(aDadosUsr[9]) == 3
			cCodErro := __aCdCri131[1]
			cTexto   := __aCdCri131[2]
		Endif
		If !lRPC
			If MsgYesNo(cTexto+" Deseja visualizar a familia deste usuario ?")
				Inclui := .F.
				BA1->(PLSA260Mov("BA1",BA1->(Recno()),K_Visualizar))
			Endif
		EndIf
		//usuario nao pode desabilitar esta critica
		PLSPOSGLO(PLSINTPAD(),cCodErro,cTexto,nil,'1',"2")
		aadd(aRet,{cCodErro,PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})	

		Return( Iif(lIncWeb, { lRet,aRet },lRet) )
		
	ElseIf  Eval( { || aDadosUsr := PLSUSRIEVE(cMatrUsr,"2",dDataBase), aDadosUsr[1] == "0" } )
		
		
		If      Val(aDadosUsr[9]) == 1
			cCodErro := __aCdCri129[1]
			cTexto   := __aCdCri129[2]
		ElseIf  Val(aDadosUsr[9]) == 2
			cCodErro := __aCdCri130[1]
			cTexto   := __aCdCri130[2]
		ElseIf  Val(aDadosUsr[9]) == 3
			cCodErro := __aCdCri131[1]
			cTexto   := __aCdCri131[2]
		Endif
		
		If !lRPC
			If MsgYesNo(cTexto+" Deseja visualizar a familia deste usuario ?")
				Inclui := .F.
				BA1->(PLSA260Mov("BA1",BA1->(Recno()),K_Visualizar))
			Endif
		EndIf	                                   
		
		//usuario nao pode desabilitar esta critica
		PLSPOSGLO(PLSINTPAD(),cCodErro,cTexto,nil,'1',"2")
		aadd(aRet,{cCodErro,PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})	
		Return( Iif(lIncWeb, { lRet,aRet },lRet) )
		
	ElseIf  aDadosUsr[1] == "1"  //intercambio eventual
		M->BER_CODINT  := aDadosUsr[3]
		M->BER_CODEMP  := aDadosUsr[4]
		M->BER_CONEMP  := aDadosUsr[5]
		M->BER_VERCON  := aDadosUsr[6]
		M->BER_SUBCON  := aDadosUsr[7]
		M->BER_VERSUB  := aDadosUsr[8]
		M->BER_TIPINT  := If(aDadosUsr[2],"1","2")
		If Len(AllTrim(M->BER_USUARI))==17
			M->BER_OPEORI := Subs(M->BER_USUARI,1,4)
		Else
			M->BER_OPEORI := "0"+Subs(M->BER_USUARI,1,3)
		Endif
		If Len(aDadosUsr) >= 10
			M->BER_NREDUZ := aDadosUsr[10]
		Endif
	Endif
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё nova implementacao. neste caso vou perguntar qual tipo de intercambio e  Ё
	//Ё e apos sua selecao irei listar todos os contratos daquele intercambio... Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aDadosUsr := PLSA235Sel(lChkCon,aRet)
	
	If ! aDadosUsr[1]
		Return(lRet)
	Else
		M->BER_TIPINT  := aDadosUsr[2]
		M->BER_CODINT  := aDadosUsr[3]
		M->BER_CODEMP  := aDadosUsr[4]
		M->BER_CONEMP  := aDadosUsr[5]
		M->BER_VERCON  := aDadosUsr[6]
		M->BER_SUBCON  := aDadosUsr[7]
		M->BER_VERSUB  := aDadosUsr[8]
		M->BER_OPEORI  := aDadosUsr[11]            
		M->BER_TELEFO  := aDadosUsr[13]

		If  ! Empty(aDadosUsr[9])
			M->BER_USUARI  := aDadosUsr[9]
		Endif
		
		If  ! Empty(aDadosUsr[10]) .And. BER->(FieldPos("BER_MATEMP")) > 0
			M->BER_MATEMP  := aDadosUsr[10]
		Endif            
		
		If Len(aDadosUsr) >= 12
			M->BER_NREDUZ := aDadosUsr[12]
		Endif
	Endif
Endif

If Empty(M->BER_CODINT) .Or. ;
	Empty(M->BER_CODEMP) .Or. ;
	Empty(M->BER_CONEMP) .Or. ;
	Empty(M->BER_VERCON) .Or. ;
	Empty(M->BER_SUBCON) .Or. ;
	Empty(M->BER_VERSUB)
	lRet   := .F.           
	cCodErro:= __aCdCri132[1]
	cTexto  := __aCdCri132[2]
	//usuario nao pode desabilitar esta critica
	PLSPOSGLO(PLSINTPAD(),cCodErro,cTexto,nil,'1',"2")
	aadd(aRet,{cCodErro,PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})		
Else
	lRefresh := .T.
	lRet     := .T.
Endif   

Return( Iif(lIncWeb, { lRet,aRet },lRet) )
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA235SEL Ё Autor Ё Tulio Cesar         Ё Data Ё 04.01.04 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Seleciona o tipo de intercambio...                         Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA235Sel(lChkCon,aRet)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina....                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Static objCENFUNLGP := CENFUNLGP():New()

LOCAL aRetPad   := {.F.}
LOCAL oDlg                          
LOCAL oGrp01
LOCAL oGrp02  
LOCAL oSay
LOCAL cCadastro := "Inclusao de Usuarios de Intercambio"
LOCAL bOK       := { || a235final(aRetPad,oContratos,aContratos,cMatricUsr,cMatricEmp,cCodOpe,cTelefone),oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL cMatricUsr:=Space(TamSX3("BER_USUARI")[1])
LOCAL cMatricEmp:=Iif( BER->(FieldPos("BER_MATEMP")) > 0 ,Space(TamSX3("BER_MATEMP")[1]),Space(17))   
LOCAL cTelefone :=Space(TamSX3("BA1_TELEFO")[1])
LOCAL cCodOpe
LOCAL cNotCods  

LOCAL aColsBE8
LOCAL aHeaderBE8
LOCAL aVetBE8   := {}
LOCAL oBrwBE8               

LOCAL oContratos
LOCAL aContratos := {{cNotContr,'','',cNotVerao,cNotVerao,"","","",cBQCCodA}}

Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}

DEFAULT lChkCon	:= .F.
DEFAULT aRet	:= {}

cNotCods := GetNewPar("MV_PLCDNIT","2 ")
cCodOpe  := PLSINTPAD()                   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados com as opcoes disponiveis...                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Store Header "BE8" TO aHeaderBE8 For .T.

BE8->(DbSetOrder(1))
BE8->(MsSeek(xFilial("BR8")))

If BE8->(Eof())
	//usuario nao pode desabilitar esta critica
	PLSPOSGLO(PLSINTPAD(),__aCdCri134[1],__aCdCri134[2],nil,'1',"2")
	aadd(aRet,{__aCdCri134[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})		
	Return(aRetPad)
Else
   Store COLS "BE8" TO aColsBE8 FROM aHeaderBE8 VETTRAB aVetBE8 For BE8->BE8_FILIAL == xFilial("BE8") .And.!(BE8->BE8_TIPINT $ cNotCods) 
   If Len(aColsBE8) == 0  
      	PLSPOSGLO(PLSINTPAD(),__aCdCri134[1],__aCdCri134[2],nil,'1',"2")
		aadd(aRet,{__aCdCri134[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","",""})		
		Return(aRetPad)	
   Endif   
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dialogo ...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1,  1, .T., .T., .F. } )
AAdd( aObjects, { 1,  1, .T., .T., .F. } )
AAdd( aObjects, { 1, 10, .T., .F., .F. } )
AAdd( aObjects, { 1, 10, .T., .F., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta browse com os tipos de intercambio...                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ aPosObj[1,1], aPosObj[1,2] GROUP oGrp01 TO aPosObj[1,3], aPosObj[1,4] PIXEL OF oDLg LABEL " Tipos de Intercambio []"

oBrwBE8 := TPLSBrw():New(aPosObj[1,1]+6,aPosObj[1,2]+3,aPosObj[1,4]-4,aPosObj[1,3]-4,nil  ,oGrp01,nil    , ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeaderBE8,aColsBE8,.F.,"BE8",K_Visualizar,"Tipos de Intercambio",nil,nil,nil,aVetBE8)
oBrwBE8:bChange := { || (oGrp01:nTop := oGrp01:nTop + 1, oGrp01:nTop := oGrp01:nTop - 1, oGrp01:cCaption := " Tipos de Intercambio [ "+AllTrim(oBrwBE8:FieldGet("BE8_DESCRI"))+" ]", CarregaDados(oContratos,aContratos,oBrwBE8,oGrp02,lChkCon)) }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta browse com os contralos relativos ao intercambio selecionado...    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ aPosObj[2,1], aPosObj[2,2] GROUP oGrp02 TO aPosObj[2,3], aPosObj[2,4] PIXEL OF oDlg LABEL " Contratos []"

oContratos := TcBrowse():New( aPosObj[2,1]+6, aPosObj[2,2]+3, aPosObj[2,4]-10, aPosObj[2,3]-aPosObj[2,1]-10,,,, oGrp02,,,,,,,,,,,, .F.,, .T.,, .F., )
oContratos:bChange := { || (oGrp02:nTop := oGrp02:nTop + 1, oGrp02:nTop := oGrp02:nTop - 1, oGrp02:cCaption := " Tipos de Intercambio [ "+AllTrim(aContratos[oContratos:nAt,1])+" ]") }

oContratos:AddColumn(TcColumn():New("Contrato",{ || aContratos[oContratos:nAt,4] },;
         "@C",nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))                        

oContratos:AddColumn(TcColumn():New("Versao",{ || aContratos[oContratos:nAt,5] },;
         "@C",nil,nil,nil,30,.F.,.F.,nil,nil,nil,.F.,nil))
         
oContratos:AddColumn(TcColumn():New("Sub contrato",{ || aContratos[oContratos:nAt,1] },;
         "@C",nil,nil,nil,100,.F.,.F.,nil,nil,nil,.F.,nil))
         
oContratos:AddColumn(TcColumn():New("Codigo Antigo",{ || aContratos[oContratos:nAt,9] },;
         "@C",nil,nil,nil,100,.F.,.F.,nil,nil,nil,.F.,nil))

@ aPosObj[3,1],aPosObj[3,2] SAY oSay PROMPT "Matricula do Usuario :"   SIZE 220,010 OF oDlg PIXEL 
@ aPosObj[3,1],aPosObj[3,2]+060 MSGET cMatricUsr                           SIZE 070,010 OF oDlg PIXEL VALID PlsChkVl(cMatricUsr,'Matricula Invalida!',.T.)

@ aPosObj[3,1],aPosObj[3,2]+135 SAY oSay PROMPT "Operadora : "  SIZE 220,010 OF oDlg PIXEL
@ aPosObj[3,1],aPosObj[3,2]+170 MSGET cCodOpe                   SIZE 020,010 OF oDlg PIXEL  F3 IIf(PlsGetVersao() >=0, "B89PLS", "B89") VALID BA0->(ExistCpo("BA0",cCodOpe,1))

@ aPosObj[4,1],aPosObj[4,2] SAY oSay PROMPT "Matricula da Empresa :"   SIZE 220,010 OF oDlg PIXEL
@ aPosObj[4,1],aPosObj[4,2]+060 MSGET cMatricEmp                           SIZE 070,010 OF oDlg PIXEL 

@ aPosObj[4,1],aPosObj[4,2]+135 SAY oSay PROMPT "Telefone             :"  SIZE 220,010 OF oDlg PIXEL 
@ aPosObj[4,1],aPosObj[4,2]+170 MSGET cTelefone                           SIZE 070,010 OF oDlg PIXEL VALID PlsChkVl(cTelefone,'Telefone Invalido!',.F.)

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BT5_NUMCON","BT5_VERSAO","BQC_DESCRI","BQC_ANTCON"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)
	Endif

		oContratos:aObfuscatedCols := aBls

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
CarregaDados(oContratos,aContratos,oBrwBE8,oGrp02,lChkCon)
oBrwBE8:oBrowse:oBrowse:nAt := 1
oContratos:Refresh()

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel) Center
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(aRetPad)



/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁCarregaDados ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  09/21/06   ╨╠╠
╠╠лммммммммммьмммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁCarrega matriz com dados dos contratos de outros intercambios..╨╠╠
╠╠╨          Ё                                                               ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                            ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function CarregaDados(oContratos,aContratos,oBrwBE8,oGrp02,lChkCon)
LOCAL cCodTipInt := oBrwBE8:FieldGet("BE8_TIPINT")
LOCAL cSQL  
LOCAL aNewContr  := {}
LOCAL lPLS235BQC := ExistBlock("PLS235BQC")
LOCAL cKeyBT5	 := ''
Local aArea      := GetArea()
LOCAL cChkCon  := GetNewPar("MV_PLSCHKC","0000")   
LOCAL lPula    := .F.

cSQL := "SELECT BT5_COBNIV, BT5_CODCLI, BT5_LOJA, BT5_CODINT, BT5_CODIGO, BT5_NUMCON, BT5_VERSAO FROM "+RetSQLName("BT5")+" WHERE "
cSQL += "BT5_FILIAL = '"+xFilial("BT5")+"' AND "
cSQL += "BT5_TIPOIN = '"+cCodTipInt+"' AND "
If lChkCon
	cSQL += "BT5_CODIGO <> '"+cChkCon+"' AND "
Endif

cSQL += "D_E_L_E_T_ = ' '"

PlsQuery(cSQL,"TrbBT5New")

While ! TrbBT5New->(Eof())
	
	cKeyBT5 := 	TrbBT5New->BT5_CODINT+TrbBT5New->BT5_CODIGO+TrbBT5New->BT5_NUMCON+;
				TrbBT5New->BT5_VERSAO
				
	BQC->(DbSetOrder(1))
	If BQC->(MsSeek(xFilial("BQC")+cKeyBT5))
		                                   
		While !BQC->( Eof() ) .and. BQC->BQC_CODIGO+BQC->BQC_NUMCON+BQC->BQC_VERSUB == cKeyBT5     
			If lPLS235BQC
            lPula := .F.
				lPula :=ExecBlock("PLS235BQC",.F.,.F.) 

				If lPula
					BQC->( dbSkip() )
					Loop
			   Endif
			Endif
			aadd(aNewContr,{BQC->BQC_DESCRI,;
			TrbBT5New->BT5_CODINT,;
			TrbBT5New->BT5_CODIGO,;
			TrbBT5New->BT5_NUMCON,;
			TrbBT5New->BT5_VERSAO,;
			BQC->BQC_SUBCON,;
			BQC->BQC_VERSUB,;
			BQC->BQC_NREDUZ,;
			BQC->BQC_ANTCON})
			
			BQC->( dbSkip() )
		Enddo
	Endif
	
	TrbBT5New->(DbSkip())
Enddo                


TrbBT5New->(DbCloseArea())
RestArea(aArea)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ordena o vetor aNewContr pela descricao do subcontrato. Bops 117346      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aNewContr := aSort(aNewContr,,, { | x, y | x[1] < y[1] })

If Len(aNewContr) > 0
   aContratos := aClone(aNewContr)
Else
   aContratos := {{cNotContr,'','',cNotVerao,cNotVerao,"","","",cBQCCodA}}
Endif

// Sempre prosiciona na primeira posicao...
oContratos:nAt := 1

oGrp02:cCaption := " Tipos de Intercambio [ "+AllTrim(aContratos[oContratos:nAt,1])+" ]"
oGrp02:nTop := oGrp02:nTop - 1
oGrp02:nTop := oGrp02:nTop + 1
oContratos:SetArray(aContratos)
oContratos:Refresh()

Return


Static Function a235final(aRetPad,oContratos,aContratos,cMatricUsr,cMatricEmp,cCodOpe,cTelefone)
LOCAL n := oContratos:nAt
DEFAULT cTelefone := ""

If Empty(cMatricUsr) .And. Empty(cMatricEmp) .And. Empty(cCodOpe)
   Help("",1,"PLSA235FIN")
   aRetPad := {.F.}
Else   
   If aContratos[n,1] <> cNotContr
      aRetPad := {.T.,"3",aContratos[n,2],aContratos[n,3],aContratos[n,4],aContratos[n,5],;
                           aContratos[n,6],aContratos[n,7],cMatricUsr,cMatricEmp,cCodOpe,;
                           aContratos[n,8],cTelefone} 
   Else
      aRetPad := {.F.}
   Endif
Endif   

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PlsChkVl   Ё Autor Ё Alexander           Ё Data Ё 06.12.05 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Chk valid do campo										  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PlsChkVl(cConteudo,cMsn,lChk)
LOCAL lRet := .T.               
cConteudo := StrTran(cConteudo,'(','')
cConteudo := StrTran(cConteudo,')','')
cConteudo := StrTran(cConteudo,'-','')
If !Empty(cConteudo)
   If Type(cConteudo) <> 'N'
   	  MsgAlert(cMsn)
   	  lRet := .F.
   EndIf	                     
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se a matricula do intercambio ja foi digitada					Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If lChk
	   SIX->(DbSetOrder(1))
	   If SIX->(MsSeek("BER2"))
	      BER->( DbSetOrder(2) )
	      If BER->( MsSeek(xFilial("BER")+AllTrim(cConteudo)) )
	         MsgAlert('Matricula informada ja CADASTRADA!')
	         lRet := .F.
	      EndIf    
	   Else 
	      MsgAlert('Favor criar o INDICE (BER_FILIAL + BER_USUARI) no BER !')
	      lRet := .F.
	   EndIf    
   EndIf	   
EndIf

Return(lRet)


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё16/03/2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё	  1 - Pesquisa e Posiciona em um Banco de Dados           Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01  ,'AxPesqui', 0 , K_Pesquisar  , 0, .T.},;
                      	{ STRPL02 ,'naodisp' , 0 , K_Visualizar , 0, Nil},;
                      	{ STRPL03    ,'naodisp' , 0 , K_Incluir    , 0, Nil} }
Return(aRotina)
                 
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Daher			        Ё Data Ё16/03/2014Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function xLSTipReg(cCodOpe,cCodEmp,cMatric,cGrauPa,cTipUsu)

LOCAL cSeqIni 	:= "00"
LOCAL cSeqFim 	:= "00"         
LOCAL cTipReg	:= "00"
LOCAL cSeq    	:= cTipReg
LOCAL lRet    	:= .T.
LOCAL lExitFor	:= .F.
LOCAL nInd    	:= 1
LOCAL aRetTpUsr := {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Parametro que indica qual o modelo a ser utilizado pela Instituicao de saude  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cModelo := GetMv("MV_PLTITCD")

If cModelo == "1"
	
	BT2->(DBSetOrder(1))
	lRet := BT2->(MsSeek(xFilial("BT2")+cGrauPa))
	
	If lRet
		cSeqIni := BT2->BT2_SEQDE
		cSeqFim := BT2->BT2_SEQATE
		cSeq    := cSeqIni 
		cSeq    := StrZero((Val(cSeq)),2)
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Pesquiso no aCols do usuario, algum usuario com o grau de parentesco que estou pesquisandoЁ
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BA1->(DbSetORder(1))
		If BA1->(MsSeek(xFilial('BA1')+cCodOpe+cCodEmp+cMatric))
			While !Ba1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodOpe+cCodEmp+cMatric
				If cGrauPa == BA1->BA1_GRAUPA
					If BA1->BA1_TIPREG == cSeq
						cSeq := StrZero((Val(cSeq)+1),2)
					EndIf             
					nRecBA1 := BA1->(Recno())
					While !Ba1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodOpe+cCodEmp+cMatric
						If BA1->BA1_TIPREG == cSeq 
							cSeq := StrZero((Val(cSeq)+1),2)
						Else
							lExitFor := .T.
							Exit
						Endif          
						Ba1->(DbSkip())
					Enddo
					BA1->(DbGoTo(nRecBA1))
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Mostro o assistente caso a quantidade de grau de parentesco ultrapasse a quantidade  |
					//Ё permitida no cadastro                                                                |
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If cSeq > cSeqFim
						lRet := .T.
						Return({cSeq,lRet})
					Endif
					If lExitFor
						Exit
					Endif
				Endif   
				Ba1->(DbSkip())
			enddo	
		Endif
		
	Endif
Else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifico as parametrizacoes para o cada tipo de usuario             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BF2->(DBSetOrder(1))
	lRet := BF2->(MsSeek(xFilial("BF2")))
	If lRet
		While !BF2->(EOF())
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se o tipo de usuario que procuro, possui uma sequencia inicial e final                  |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If AllTrim(cTipUsu) $ AllTrim(BF2->BF2_GRAUPA)
				cSeqIni := BF2->BF2_SEQDE
				cSeqFim := BF2->BF2_SEQATE
				cSeq    := cSeqIni
				cSeq    := StrZero((Val(cSeq)),2)
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Pesquiso no aCols do usuario, algum usuario com o grau de parentesco que estou pesquisandoЁ
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BA1->(DbSetORder(1))
				If BA1->(MsSeek(xFilial('BA1')+cCodOpe+cCodEmp+cMatric))
					While !Ba1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodOpe+cCodEmp+cMatric
					
							If BA1->BA1_TIPUSU $ AllTrim(BF2->BF2_GRAUPA)
								cSeq := StrZero((Val(cSeq)+1),2)
							Elseif BA1->BA1_TIPREG $ Alltrim(cSeq)
								cSeq := StrZero((Val(cSeq)+1),2)
								nInd := 0
							Endif
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Mostro o assistente caso a quantidade de grau de parentesco ultrapasse a quantidade  |
							//Ё permitida no cadastro                                                                |
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If cSeq > cSeqFim
								lRet := .F.
								Return({cSeq,lRet})
							Endif
						BA1->(DbSkip())
					enddo           
					BA1->(DbSetORder(2))
					while BA1->(MsSeek(xFilial('BA1')+cCodOpe+cCodEmp+cMatric+cSeq))
					     cSeq := strzero(val(cSeq)+1,2)
					     BA1->(DbSkip())
					enddo
				Endif
			Endif
			BF2->(DBSkip())
		Enddo
	Endif
Endif

Return({cSeq,lRet})
