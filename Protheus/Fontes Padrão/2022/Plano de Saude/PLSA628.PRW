#INCLUDE "PLSA628.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#define K_Imprimir  K_Alterar

Static nGravado := 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA628
Geracao de Cobranca de intercambio eventual. 

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function PLSA628()
PRIVATE aRotina 	:= MenuDef()
PRIVATE cCadastro 	:= FunDesc() //"Lotes de Intercambio"                       
PRIVATE nLeg	 	:= 0
PRIVATE lIntegracao := IF(GetMV("MV_EASY")=="S",.T.,.F.) // utilizado na FA040DELET()
PRIVATE lF040Auto   := .T.

//Endereca a funcao de BROWSE
BTF->(DbSetOrder(1))
BTF->(DbSeek(xFilial("BTF")))
BTF->(mBrowse(06,01,22,75,"BTF",,,,,,)) //aCores

Return
              
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL628MOV
Movimentacao da geracao de cobranca intercambio eventual

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function PL628MOV(cAlias, nReg, nOpc, lDelDireto, lAuto)
Local I__f := 0
Local nCols
Local nCnt
Local j

//Define Variaveis...                                                  

local aButtons	:= {}
local aRet      := {}    
local aNumTit	:= {}
local nOpca	 	:= 0
local nSeq		:= 0
local cSql	 	:= ""
local oEnchoice
local oDlg	
local nN1BTO_PREFIX := 0
local nN1BTO_NUMTIT := 0
local nN1BTO_PARCEL := 0
local aTit			:= {} 
local cOpePEA		:= GetNewPar("MV_PLOPPEA","0999")
local cIntPEA		:= GetNewPar("MV_PLINPEA","99")
local lEmpresa		:= .F.
local k				:= 1           
local I				:= 1           
local _nH      
local aGeralTit		:= {}   
local l_Exclui 		:= .T.
PRIVATE aSize 	 	:= {}
PRIVATE aObjects 	:= {}       
PRIVATE aInfo 	 	:= {}
PRIVATE aPosObj 	:= {}
PRIVATE lAbortPrint := .F.
PRIVATE oFolder	
PRIVATE lDadNiv  	:= {0,0,0,0,0,0,0}
PRIVATE lDadCri  	:= {0,0,0,0,0,0,0}
PRIVATE oGetCri1
PRIVATE oGetSE1G
PRIVATE cOpeOri		:= ''
PRIVATE cSequen 	:= '001'
PRIVATE cPrefix 	:= ''
PRIVATE cNumTit 	:= ''
PRIVATE cParcel 	:= ''

PRIVATE cCodInt  	:= If(nOpc == K_Incluir, 	Space(Len(BDC->BDC_CODOPE)),;
											 	BDC->BDC_CODOPE)
PRIVATE nOpcX	 	:= nOpc


//Browse resumo...                                                

PRIVATE aCabBTO := {}
PRIVATE aDadBTO := {}
PRIVATE aVetBTO := {}
PRIVATE oBrwBTO


//Titulos cancelados...
PRIVATE aCabBTV  := {}
PRIVATE aDadBTV  := {}
PRIVATE oGetBTV 

//Titulos gerados...
PRIVATE aCabSE1G 	:= {}
PRIVATE aDadSE1G 	:= {}

//Criticas...                                                     

PRIVATE aDadCri1    := {}
PRIVATE aCabCri1	:= {}
default lAuto 		:= .f.

//Imprime resumo da cobranca...
If nOpc == K_Imprimir
	PLSR591(BTO->BTO_CODOPE, BTO->BTO_CODOPE, BTO->BTO_NUMERO, BTO->BTO_NUMERO,;
	        BTO->BTO_OPEORI, BTO->BTO_OPEORI, 1, 2)
	Return
Endif

//Monta dados do cabecalho...
If nOpc == K_Incluir
	Copy "BTF" TO Memory Blank
Else
	Copy "BTF" TO MEMORY                 
	
	
	//Carrega matriz de status...                                          
	
	Store Header "BTO" TO aCabBTO For .T.
	If BTO->( dbSeek(xFilial("BTO")+BTF->BTF_CODOPE+BTF->BTF_NUMERO) )
		Store COLS "BTO" TO aDadBTO FROM aCabBTO VETTRAB aVetBTO While BTO->(BTO_FILIAL+BTO_CODOPE+BTO_NUMERO) == xFilial("BTF")+BTF->(BTF_CODOPE+BTF_NUMERO)
		cOpeOri := aDadBTO[1,PlRetPos("BTO_OPEORI",aCabBTO,.F.)]		
	Else
	    Store COLS Blank "BTO" TO aDadBTO FROM aCabBTO
	Endif
	
	
	//Carrega todas as criticas que houveram...                                    
	
	Store Header "BTG" TO aCabCri1 For .T.
	BTG->(DbSetOrder(1))
	If BTG->(DbSeek(xFilial("BTG")+BTF->BTF_CODOPE+BTF->BTF_NUMERO+"1"))
		Store COLS "BTG" TO aDadCri1 FROM aCabCri1 While BTG->(BTG_FILIAL+BTG_CODOPE+BTG_NUMERO+BTG_NIVEL) == (xFilial("BDG")+BTF->BTF_CODOPE+BTF->BTF_NUMERO+"1")
	Else
		Store COLS Blank "BTG" TO aDadCri1 FROM aCabCri1
		lDadCri[1]:= 1
	EndIf           
	
	
	//Carrega o contas a receber....                                               
	
	Store Header "SE1" TO aCabSE1G For .T.

	
	//Ajusta o aCols do SE1...                                                     
	
	Aadd(aCabSe1G, AClone(aCabSe1G[1]))
	aCabSe1G[Len(aCabSe1G)][1] := STR0016 //"Status"
	aCabSe1G[Len(aCabSe1G)][2] := "E1_STATUS"
	aCabSe1G[Len(aCabSe1G)][3] := "@BMP"
	aCabSe1G[Len(aCabSe1G)][4] := 0	
	aCabSe1G[Len(aCabSe1G)][10] := "V"  

	
	//Ajusta aHeader do SE1...                                                     
		
	aHeader := {}
	Aadd(aHeader, aCabSe1G[Len(aCabSe1G)])
	For nCols := 1 To Len(aCabSe1G) - 1
		Aadd(aHeader, aCabSe1G[nCols])
	Next
	aCabSe1G := AClone(aHeader)

	Store COLS Blank "SE1" TO aDadSE1G FROM aCabSE1G
	aDadSe1G[1][1] := ""

	nCols := 1
	nLido := 0
	
	//Obtem pocisao das colunas relativas ao titulo no array de operadoras	
	nN1BTO_PREFIX := Ascan(aCabBTO, { |x| AllTrim(x[2]) = "BTO_PREFIX" })
	nN1BTO_NUMTIT := Ascan(aCabBTO, { |x| AllTrim(x[2]) = "BTO_NUMTIT" })
	nN1BTO_PARCEL := Ascan(aCabBTO, { |x| AllTrim(x[2]) = "BTO_PARCEL" })
	nN1BTO_TITTIP := Ascan(aCabBTO, { |x| AllTrim(x[2]) = "BTO_TIPTIT" })
                                                                                          
	
	//Funcao generica para carga do acols do SE1...                                
	
	Pl628CarSE1(aDadBTO, @nCols, @nLido, nN1BTO_PREFIX, nN1BTO_NUMTIT, nN1BTO_PARCEL,;
				nN1BTO_TITTIP, 5, aDadSE1G, "0", BTF->(BTF_CODOPE+BTF_NUMERO))
	
	//Inicializa variaveis utilizadas no bFilter do objeto de titulos gerados...   	
	cPrefix := aDadSE1G[1,PlRetPos("E1_PREFIXO"	,aCabSe1G,.F.)]
	cNumTit := aDadSE1G[1,PlRetPos("E1_NUM"		,aCabSe1G,.F.)]
	cParcel := aDadSE1G[1,PlRetPos("E1_PARCELA"	,aCabSe1G,.F.)]
	
	//Titulos cancelados...                                                        
	Store Header "BTV" TO aCabBTV  For .T.
	BTV->(DbSetOrder(2))
	If BTV->(DbSeek(xFilial("BTV")+BTF->BTF_CODOPE+BTF->BTF_NUMERO+'101')) // Busca exclusivamente por lotes de intercambio eventual...
		Store COLS "BTV" TO aDadBTV FROM aCabBTV While BTV->(BTV_FILIAL+BTV_PLNUCO+BTV_INTERC+BTV_TIPINT) == xFilial("BTF")+BTF->BTF_CODOPE+BTF->BTF_NUMERO+'101'
	Else
		Store COLS Blank "BTV" TO aDadBTV FROM aCabBTV
	EndIf
	
Endif

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 200, .T., .T. } )
AAdd( aObjects, { 200, 100, .T., .T.,.T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

nGravado := 0
If (nOpc # K_Excluir .Or. (nOpc = K_Excluir .And. ! lDelDireto))
	
	//Define Dialogo...                                                    
	if !lAuto
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL 

		//Monta Enchoice...                                                    

		oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)


		If nOpc <> K_Incluir
			@ aPosObj[2][1]+20,aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg  PIXEL	PROMPTS	STR0017,STR0018,STR0019,STR0020 //"Resultado"###"Criticas"###"Titulos gerados"###"Titulos cancelados"

			oBrwBTO:= TPLSBrw():New(001,001,aPosObj[2][3]-5,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBTO ,aDadBTO ,.F.      ,"BTO" ,K_Visualizar,STR0021,nil,nil,nil,aVetBTO) //"Operadoras"
			oBrwBTO:bLostFocus 	:=	{|| cOpeOri := oBrwBTO:FieldGet("BTO_OPEORI"),;
										cSequen := oBrwBTO:FieldGet("BTO_SEQUEN"),;
										cPrefix := oBrwBTO:FieldGet("BTO_PREFIX"),;
										cNumTit := oBrwBTO:FieldGet("BTO_NUMTIT"),;
										cParcel := oBrwBTO:FieldGet("BTO_PARCEL"),;
										lRefresh := .T. }									

			oBrwBTO:bChange		:= 	{|| Eval(oBrwBTO:bLostFocus),;
										Iif(Type('oGetCri1')<>"U",oGetCri1:ForceRefresh(oBrwBTO),NIL),;
										Iif(Type('oGetSE1G')<>"U",oGetSE1G:ForceRefresh(oBrwBTO),NIL),;
										Iif(Type('oGetBTV' )<>"U",oGetBTV:ForceRefresh(oBrwBTO),NIL)  }


			@ aPosObj[1][3]+10,005 BITMAP oBmp RESNAME "BR_VERDE" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
			@ aPosObj[1][3]+10,015 Say oSay PROMPT STR0022 SIZE 040,010 OF oDlg PIXEL //"Faturado"

			@ aPosObj[1][3]+10,055 BITMAP oBmp RESNAME "BR_VERMELHO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
			@ aPosObj[1][3]+10,065 Say oSay PROMPT STR0023 SIZE 040,010 OF oDlg PIXEL		 //"Criticado"

			@ aPosObj[1][3]+10,105 BITMAP oBmp RESNAME "BR_LARANJA" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
			@ aPosObj[1][3]+10,115 Say oSay PROMPT STR0024 SIZE 040,010 OF oDlg PIXEL //"Cancelado"

			@ aPosObj[1][3]+10,155 BITMAP oBmp RESNAME "BR_AZUL" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
			@ aPosObj[1][3]+10,165 Say oSay PROMPT STR0025 SIZE 100,010 OF oDlg PIXEL //"Nao Selecionado"

		Cr628FolCri(nOpc)		
		Else
			@ aPosObj[2][1]+20,aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4]  OF oDlg  PIXEL	PROMPTS	STR0017	 //"Resultado"
		Endif

		//Ativa o Dialogo...                                                   

		ACTIVATE MSDIALOG oDlg ON INIT (Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela) .And. VerTipCob() .And. If(nOpc = K_Incluir, MsgYesNo(STR0026), .T.),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,aButtons)  }))	 //"Confirma os parametros informados ?"
	else
		nOpca 	:= K_OK
		nOpc 	:= K_Incluir
	endif
Else
	nOpca := If(nOpc = K_Excluir .And. lDelDireto, K_OK, 0)
Endif

if lAuto .and. nOpc == K_Incluir
	M->BTF_FILIAL := xfilial("BTF")
	M->BTF_DESOPE := "OPERADORA 417505                        "
	M->BTF_NUMERO := "00000039"
	M->BTF_DATGER := date()
	M->BTF_USUOPE := "Administrador            "
	M->BTF_HORA   := "00:00:40"
	M->BTF_ANOINI := "2021"
	M->BTF_MESINI := "05"
	M->BTF_VENCTO := date()
	M->BTF_TIPCOB := "1"
	M->BTF_CODINT := "0050"
	M->BTF_OPEGER := 0
	M->BTF_OPECRI := 0
	M->BTF_NOSELE := 0
	M->BTF_OPECAN := 0
	M->BTF_VLRCOP := 0
	M->BTF_VLRCP2 := 0
	M->BTF_VLRTAX := 0
	M->BTF_VLRCP3 := 0
	M->BTF_CUSTOT := 0
	M->BTF_DTEMIS := date()
	M->BTF_TIPPAC := "1"
	M->BTF_RETROA := "1"
endif

//Rotina de gravacao dos dados...
If nOpca == K_OK
	If nOpc == K_Incluir
	    
        //Ponto de entrada para avaliar a continuidade do processo               
        
        If ExistBlock("PL628INC")
           If !Execblock("PL628INC",.F.,.F.,{dDataBase})  
              Return .F.               
		   EndIf
	    EndIf
		                       
		
		//Se for faturamento do PEA ou Fundacao, tem que atualizar o campo BDH_OPEORI      
		
		If  M->BTF_REEANE $ " 0"
			If M->BTF_TIPCOB $ '2,3,9 '
				If M->BTF_TIPCOB == '2' // Apenas PEA
					cIntPEA		:= GetNewPar("MV_PLINPEA","99")
					lEmpresa	:= .F.
					nFor := 1
				Elseif M->BTF_TIPCOB == '3' // Apenas fundacao
					cIntPEA		:= GetNewPar("MV_PLINFDC","98")
					cOpePEA 	:= M->BTF_CODOPE
					lEmpresa	:= .T.
					nFor := 1
				Elseif M->BTF_TIPCOB $ '9, ' // Todos...
					cIntPEA		:= 	GetNewPar("MV_PLINPEA","99")
					lEmpresa	:= .F.
					nFor := 2
				Endif
    
				For nCnt := 1 To nFor				
					cSQL := "SELECT BT5_CODINT, BT5_CODIGO, BT5_NUMCON, BT5_VERSAO, BT5_INTERC FROM "+RetSQLName("BT5")+" WHERE "
					cSQL += "BT5_FILIAL = '"+xFilial("BT5")+"' AND "
					cSQL += "BT5_TIPOIN = '"+cIntPea+Space(2-(Len(Alltrim(cIntPea))))+"'  AND "
					cSQL += "D_E_L_E_T_ = ' '"
				
					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TrbBT5", .F., .T.)
				
				
					While !TrbBT5->( Eof() )                           
						
						cSql := "SELECT BDH.R_E_C_N_O_ REG_NUMBER FROM "+RetSqlName("BDH")+" BDH, "+RetSqlName("BA1")+" BA1 WHERE BDH_CODINT = BA1_CODINT "
						cSql += "AND BDH_CODEMP = BA1_CODEMP "
						cSql += "AND BDH_MATRIC = BA1_MATRIC "
						cSql += "AND BDH_TIPREG = BA1_TIPREG "           
						cSql += "AND BDH_STATUS = '1' "
						cSql += "AND BDH_NUMFAT = ' ' "
						cSql += "AND BA1_CODINT = '"+TrbBT5->BT5_CODINT+"' "
						cSql += "AND BA1_CODEMP = '"+TrbBT5->BT5_CODIGO+"' "
						cSql += "AND BA1_CONEMP = '"+TrbBT5->BT5_NUMCON+"' "
						cSql += "AND BA1_VERCON = '"+TrbBT5->BT5_VERSAO+"' "
						cSql += "AND BDH.D_E_L_E_T_ = ' ' "
						cSql += "AND BA1.D_E_L_E_T_ = ' ' "
				
				 		cSQL := ChangeQuery(cSQL)
						dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TrbBDH", .F., .T.)

						
					    While !TrbBDH->( Eof() )
					    	BDH->( dbGoto(TrbBDH->REG_NUMBER) )
					    	If !BDH->( Eof() )
				    			BDH->( RecLock("BDH", .F.) )
				    				BDH->BDH_OPEORI := cOpePEA
				    				BDH->BDH_INTERC := TrbBT5->BT5_INTERC
				    				BDH->BDH_TIPINT := cIntPea		// Marca como intercambio...				    				
				    				If lEmpresa
				    					BDH->BDH_EMPORI := TrbBT5->BT5_CODIGO
				    				Endif
				    			BDH->( MsUnlock() )
					    	Endif
					    
					    	TrbBDH->( dbSkip() )
					    Enddo
				    	     
					    TrbBDH->( dbClosearea() )
						TrbBT5->( dbSkip() )
					Enddo                    
					
					// Fundacao, para atualizar o campo BDH_OPEORI com os dados da operadora LOCAL.
					If nFor == 2
						cCodPEA := GetNewPar("MV_PLINFDC","98")
						cOpePEA := M->BTF_CODOPE
						lEmpresa	:= .T.
					Endif
					
					TrbBT5->( dbCloseArea() )
				Next
			Endif
		Endif
		
		//Executa funcao para gerar itens...                                   
		
		//Primeiro Verifico se o periodo esta correto
		If M->BTF_REEANE == "1"
			Processa( {|| aRet := A628Aneste(M->BTF_NUMERO,M->BTF_ANOINI,M->BTF_MESINI, M->BTF_CODOPE, cOpePEA) },"Apurando Valores Anestesista",STR0028+M->BTF_MESINI+"  /  " + STR0071+M->BTF_ANOINI,.T. ) //"Apurando Valores"###"Apurando Mes:" //"Ano:"
        Else
			Processa( {|| aRet := A628Itens(M->BTF_NUMERO,M->BTF_ANOINI,M->BTF_MESINI, M->BTF_CODOPE, cOpePEA, lAuto) }, STR0027,STR0028+M->BTF_MESINI+"  /  " + STR0071+M->BTF_ANOINI,.T. ) //"Apurando Valores"###"Apurando Mes:" //"Ano:"
        Endif
		
		//Grava e exibe o LOTE...                                              
		
		If aRet[1]       
			
			//Inicia a transacao...                                                
							
			_nH := PLSAbreSem("PLSA628.SMF") // Semaforo do lote de intercambio
			
			nTitulos := Len(aRet[2])
			If M->BTF_TPCOB <> '3'
				For j := 1 To nTitulos
					
					//Gera o numero e o tipo do titulo...                   			
							
				    If aRet[2,J,6] // Verifico se o item foi selecionado.
						aNumTit  := PLSA625MDa(M->BTF_ANOINI,M->BTF_MESINI,"1","2",nil,"6") 
					Endif	
					AaDd(aGeralTit,aNumTit)
				Next
			EndIf
			Begin transaction 
		
			
			//Grava cabecalho da geracao da cobranca...                            
					
			PLUPTENC("BTF",nOpc)		
			
			For k := 1 To nTitulos
				nSeq++
				If M->BTF_REEANE == "1"// Reembolso PTU
					Processa( {|| aTit := A628GrvAne(aRet,k,nSeq,Iif(M->BTF_TPCOB <> '3',aGeralTit[k],{}),;
				    M->BTF_TPCOB)}, STR0029,"",.T. )//"Gerando Titulos"
				Else
					Processa( {|| aTit := A628Grava(aRet,k,nSeq,Iif(M->BTF_TPCOB <> '3',aGeralTit[k],{}),;
				    M->BTF_TPCOB)}, STR0029,"",.T. )//"Gerando Titulos"
				Endif
			Next		
			
			Inclui := .F.			
			
 			//Finaliza transacao...                                                
			        
  			BTF->(CONFIRMSX8())
  		
  			End Transaction 			
			
			PLSFechaSem(_nH,"PLSA628.SMF")
						
 			If !lAuto .and. !PL628MOV(cAlias,BTF->(Recno()),K_Visualizar) 
			Endif
			
		Endif                                                                                          
		
	ElseIf nOpc == K_Excluir
		
		//Ponto de Entrada para validar se o lote vai ou nao ser excluido		
        If ExistBlock("PL628EXC")
           If !Execblock("PL628EXC",.F.,.F.)  
              MsgAlert(STR0030)  //"Nao e possivel excluir o Lote!"
			  Return .F.               
		   EndIf
	    EndIf
		
		//Inicia transacao...                                                  
		_nH := PLSAbreSem("PLSA628.SMF")
		
		Begin Transaction
		
		//Exclui titulos a receber...                                          
		
		// Se Lote de Reembolso de Anestesista
		If BTF->BTF_REEANE == "1"
	    	l_Exclui := PLSASE1ANE(BTF->(BTF_CODOPE+BTF_NUMERO))
	 	Else
	 		l_Exclui := PLSA628SE1(BTF->(BTF_CODOPE+BTF_NUMERO))
	 	Endif
	 	
	 	If l_Exclui
			Pl628Exc(BTF->BTF_CODOPE, BTF->BTF_NUMERO, "0")
		
			PLUPTENC("BTF",nOpc)
		Endif
		
		//Finaliza transacao...                                                
		
		End Transaction
		
		PLSFechaSem(_nH,"PLSA628.SMF")

	Endif
Else 
	If nOpc == K_Incluir
	   	BTF->(RollBackSX8())
	Endif		
EndIf


Return nOpca == K_OK

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A628Itens
Inclusao de bordero de pagamento.

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function A628Itens(	cNumCob,cAno,cMes,cOperadora,cOpePEA,lAuto)

LOCAL cSql 		:= ''
LOCAL cOpe 		:= ''
LOCAL cChave	:= ''
LOCAL cCodCli 	:= ''
LOCAL cCodLoj 	:= ''  
LOCAL cNaturez	:= ''
LOCAL lRet		:= iif(lAuto,.t.,.f.)
LOCAL cNameBSQ := RetSQLName("BSQ")
LOCAL cNameBSP := RetSQLName("BSP")
LOCAL aValOpe   := {}
LOCAL bOk		:= {|| Iif(PL268OK(aValOpe), (lRet:=.T., oDlg:End()), NIL)}
LOCAL bCancel	:= {|| Iif(MsgYesNo(STR0031),(lRet:=.F., oDlg:End()),NIL)} //"Deseja Abandorar o Lote?"
LOCAL nCnt		:= 0
LOCAL dVenc		:= cTod('')
LOCAL lCliEsp	:= .F.
LOCAL oGrupo1
LOCAL oGrupo2
LOCAL oSay		       
LOCAL lAglut	 := .F.
LOCAL cAnoMes := cAno + cMes //PLSDIMAM(cAno,cMes,"0")
LOCAL cProduto   := ""
LOCAL cTes       := ""
LOCAL cPlano     := ""
LOCAL cVersao    := ""
LOCAL nPos       := 0
LOCAL nDiasSrvPrt := GetNewPar("MV_PLDIAPZ",150)

//Monta query principal com os registros de intercambio eventual...
cSql := "SELECT  BDH.BDH_OPEORI,BDH.BDH_VLRTAX,BDH.BDH_VLRCP2,BDH.BDH_VLRCOP,BDH.BDH_CODINT,"
cSql += 		"BDH.BDH_EMPORI,BDH.BDH_CODEMP,BDH.BDH_MATRIC,BDH.BDH_TIPREG,BDH.R_E_C_N_O_ "

If M->BTF_TIPCOB $ '2, 3, '
	cSql += ", BDH.BDH_VALOR, BDH.BDH_VLRTAX "
Endif

cSql += " ,BDH.BDH_VLRCP3, BDH.BDH_VLRCP4, BDH.BDH_VLRCP5, BDH.BDH_VLRCP6, BDH.BDH_VLRCP7, BDH.BDH_VLRCP8 "
cSql += " ,BDH.BDH_VLRCP9, BDH.BDH_VLRCPA, BDH.BDH_VLRCPB, BDH.BDH_VLRCPC, BDH.BDH_TIPPAC "
cSql += " ,BDH.BDH_VLRT11, BDH.BDH_VLRT12, BDH.BDH_VLRT13, BDH.BDH_VLRT14, BDH.BDH_VLRT15, BDH.BDH_VLRT16 "
cSql += " ,BDH.BDH_VLRT17, BDH.BDH_VLRT18, BDH.BDH_VLRT19, BDH.BDH_VLRT1A, BDH.BDH_VLRT1B, BDH.BDH_VLRT1C "
cSql += " FROM " + RetSqlName("BDH") + " BDH "

//Relacionamento BA0
cSql += "INNER JOIN " + RetSqlName("BA0") + " BA0 "
cSql += "ON ( BA0.BA0_FILIAL = BDH.BDH_FILIAL "
cSql += "AND  BA0.BA0_CODIDE = SUBSTRING(BDH.BDH_OPEORI,1,1) "
cSql += "AND  BA0.BA0_CODINT = SUBSTRING(BDH.BDH_OPEORI,2,3) "
cSql += "AND  BA0.D_E_L_E_T_ = BDH.D_E_L_E_T_ ) "

//Relacionamendo com os eventos (Caso a cobranca retroativa esteja ativada)
cData := DtoS( ( M->BTF_DATGER - nDiasSrvPrt ) )
	
//Relacionamendo BD6
cSql += "INNER JOIN " + RetSqlName("BD6") + " BD6 "
cSql += "ON ( BD6.BD6_FILIAL = BDH.BDH_FILIAL "
cSql += "AND BD6.BD6_OPEUSR = BDH.BDH_CODINT "
cSql += "AND BD6.BD6_CODEMP = BDH.BDH_CODEMP "
cSql += "AND BD6.BD6_MATRIC = BDH.BDH_MATRIC "
cSql += "AND BD6.BD6_ANOPAG = BDH.BDH_ANOFT  "
cSql += "AND BD6.BD6_MESPAG = BDH.BDH_MESFT  "
cSql += "AND BD6.D_E_L_E_T_ = ' ' ) "
	
//Relacionamendo BD5
cSql += "LEFT JOIN " + RetSqlName("BD5") + " BD5  " 
cSql += "ON ( BD5.BD5_FILIAL = BD6.BD6_FILIAL " 
cSql += "AND BD5.BD5_CODOPE = BD6.BD6_CODOPE  " 
cSql += "AND BD5.BD5_CODLDP = BD6.BD6_CODLDP  " 
cSql += "AND BD5.BD5_CODPEG = BD6.BD6_CODPEG  " 
cSql += "AND BD5.BD5_NUMERO = BD6.BD6_NUMERO  " 
cSql += "AND BD6_TIPGUI NOT IN ('03','05') "
If M->BTF_RETROA <> '1'   
	cSql += "AND BD5.BD5_DATPRO >= '" + cData + "' "
    Else	
	cSql += "AND BD5.BD5_DATPRO < '" + cData + "' "
EndIf
cSql += "AND BD5.D_E_L_E_T_ = ' ' ) " 
	
//Relacionamendo BE4
cSql += "LEFT JOIN " + RetSqlName("BE4") + " BE4 "
cSql += "ON ( BE4.BE4_FILIAL = BD6.BD6_FILIAL "
cSql += "AND BE4.BE4_CODOPE = BD6.BD6_CODOPE "
cSql += "AND BE4.BE4_CODLDP = BD6.BD6_CODLDP "
cSql += "AND BE4.BE4_CODPEG = BD6.BD6_CODPEG "
cSql += "AND BE4.BE4_NUMERO = BD6.BD6_NUMERO "
cSql += " AND BD6_TIPGUI IN ('03','05') "
If M->BTF_RETROA <> '1'
	cSql += "AND BE4.BE4_DTALTA >= '" + cData + "' "
Else	
	cSql += "AND BE4.BE4_DTALTA < '" + cData + "' "
EndIf
cSql += "AND BE4.D_E_L_E_T_ = ' ' )"


cSql += " WHERE BDH.BDH_FILIAL = '"+xFilial("BDH")+"' "
cSql += "AND BDH.BDH_INTERC  = '1' "
cSql += "AND BDH.BDH_TIPINT <> ' ' "

If M->BTF_TIPCOB == '1'  // Intercambio eventual.		
	cSql += "AND BDH.BDH_OPEORI <> '"+cOpePEA+"' "
Elseif M->BTF_TIPCOB == '2' // PEA.
	cSql += "AND BDH.BDH_OPEORI = '"+cOpePEA+"' "	
	
Elseif M->BTF_TIPCOB $ '3,9 ' // Fundacao ou todas.
	cSql += "AND BDH.BDH_OPEORI <> ' ' "
Endif

If M->BTF_TIPPAC == '1'
	cSql += "AND BDH.BDH_TIPPAC  = '1' "
ElseIf 	M->BTF_TIPPAC == '2'
	cSql += "AND BDH.BDH_TIPPAC  = '2' "
Endif

cSql += "AND BDH.BDH_STATUS  = '1' "
cSQL += "AND (BDH.BDH_ANOFT < '" + Subs(cAnoMes,1,4) + "' OR ( BDH.BDH_ANOFT = '" + Subs(cAnoMes,1,4) + "' AND BDH.BDH_MESFT  <= '" + Subs(cAnoMes,5,2) + "' )) "
cSql += "AND BDH.D_E_L_E_T_ = ' ' "

If !Empty(M->BTF_GRUOPE)
	cSql += "AND BA0.BA0_GRUOPE = '"+M->BTF_GRUOPE+"' "
Endif

//Trata cobranca retroativa inferior a data estabelecida no manual
cSQL += " AND	( BD6.BD6_CONCOB = '1' OR BD6.BD6_CONCOB = ' ' ) "
cSQL += " AND	BD6.BD6_VLRTPF > 0 "
cSQL += " AND	BD6.BD6_FASE IN ('3','4') "
cSQL += " AND	BD6.BD6_SITUAC  = '1' "
cSQL += " AND	BD6.BD6_SEQPF   <> ' ' "
cSQL += " AND	BD6.BD6_BLOCPA <> '1' "

If M->BTF_RETROA <> '1'   
	cSQL += " AND (BD5.BD5_DATPRO <> '" + Space(TamSX3("BD5_DATPRO")[1]) + "' OR BE4.BE4_DATPRO <> '" + Space(TamSX3("BE4_DATPRO")[1]) + "') "
EndIf

cSQL += " GROUP BY  BDH.BDH_OPEORI,BDH.BDH_VLRTAX,BDH.BDH_VLRCP2,BDH.BDH_VLRCOP,BDH.BDH_CODINT,BDH.BDH_EMPORI,BDH.BDH_CODEMP,BDH.BDH_MATRIC,BDH.BDH_TIPREG,  "
cSQL += " BDH.R_E_C_N_O_ , BDH.BDH_VALOR , BDH.BDH_VLRCP3 , BDH.BDH_VLRCP4 , BDH.BDH_VLRCP5 , BDH.BDH_VLRCP6 , BDH.BDH_VLRCP7 , BDH.BDH_VLRCP8 , BDH.BDH_VLRCP9 ,  "
cSQL += " BDH.BDH_VLRCPA , BDH.BDH_VLRCPB , BDH.BDH_VLRCPC , BDH.BDH_TIPPAC , BDH.BDH_VLRT11, BDH.BDH_VLRT12, BDH.BDH_VLRT13, BDH.BDH_VLRT14, BDH.BDH_VLRT15,  "
cSQL += " BDH.BDH_VLRT16, BDH.BDH_VLRT17 , BDH.BDH_VLRT18, BDH.BDH_VLRT19, BDH.BDH_VLRT1A, BDH.BDH_VLRT1B, BDH.BDH_VLRT1C " 
cSql += " ORDER BY BDH.BDH_OPEORI, BDH.BDH_EMPORI"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TRB1", .F., .T.)


//Acumula os valores por operadoras...                                 

If M->BTF_TIPCOB <> '4'
	TRB1->( dbGotop() )
	While !TRB1->( Eof() )
	
		// Verifica se o registro possui valor para ser cobrado... istou foi retirado da query para melhorar
		// o tempo de resposta do banco, ja que nao exite indices para campos de valores.
		nValBDH := TRB1->(BDH_VLRCOP + BDH_VLRCP2 + BDH_VLRTAX)
	
		
		nValBDH += 	TRB1->(	BDH_VLRT11 + BDH_VLRT12 + BDH_VLRT13 + BDH_VLRT14 +;
					BDH_VLRT15 + BDH_VLRT16 + BDH_VLRT17 + BDH_VLRT18 +;
					BDH_VLRT19 + BDH_VLRT1A + BDH_VLRT1B + BDH_VLRT1C )		
		 
		nValBDH += 	TRB1->(	BDH_VLRCP3 + BDH_VLRCP4 + BDH_VLRCP5 + BDH_VLRCP6 +;
				   	BDH_VLRCP7 + BDH_VLRCP8 + BDH_VLRCP9 + BDH_VLRCPA +;
				   	BDH_VLRCPB + BDH_VLRCPC )
		
        
		If nValBDH <= 0
			Trb1->(DbSkip())
			Loop
		Endif
				
		
		//Verifica se contrato (BT5) e de custo operacional...                 
		
		BA3->(DbSetOrder(1))
		If BA3->(DbSeek(xFilial("BA3")+Trb1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC)))
			BT5->(DbSetOrder(1))
			If BT5->(DbSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON)))
				If BT5->BT5_MODPAG <> "2" //Se nao for for de custo operacional devera ser faturada como
					Trb1->(DbSkip())
					Loop
				Endif
			Endif
		Endif
		
		//Variaveis agrupadoras... controle do loop...                         
		
		cOpe := TRB1->BDH_OPEORI
		cEmp := TRB1->BDH_EMPORI
		
		
		//Posiciona a operadora...                                             
		
		BAO->( dbSetorder(01) )
		BA0->( dbSeek(xFilial("BA0")+cOpe) )
		
		
		//Verifica intercambio com clientes especificos... caso contrario, cliente sera o da operadora  		
		cNaturez := ' '
		BMP->( dbSetorder(01) )
		If BMP->( dbSeek(xFilial("BMP")+TRB1->(BDH_OPEORI+BDH_EMPORI)) )
			lCliEsp := .T.
			cTipAgl := BMP->BMP_AGLUTI
			cCodCli := BMP->BMP_CODCLI
			cCodLoj := BMP->BMP_LOJA
		Else
			If BT5->BT5_COBNIV $ "0, "
				lCliEsp := .F.
				lAglut	:= .F.
				cCodCli := BA0->BA0_CODCLI
				cCodLoj := BA0->BA0_LOJCLI
			Else
				lCliEsp := .F.
				lAglut	:= .F.
				cCodCli := BT5->BT5_CODCLI
				cCodLoj := BT5->BT5_LOJA
				cNaturez := BT5->BT5_NATURE
			Endif
		Endif
		
		
		//Obtem a natureza para geracao do titulo...                           
		
		If Empty(cNaturez)
			cNaturez := BA0->BA0_NATURE
		Endif
		
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+cCodCli+cCodLoj))
		
		
		//Inicia o processamento...                 
		
		While ! TRB1->( Eof() ) .and. TRB1->BDH_OPEORI == cOpe .and. TRB1->BDH_EMPORI == cEmp
			
			//Filtra tipo de faturamento determinado pelo usuario...               
			
			If M->BTF_TIPCOB == '1' // Apenas Intercambio eventual.
				If lCliEsp
					TRB1->( dbSkip() )
					Loop
				Endif
				
			Elseif M->BTF_TIPCOB == '3' 
				If !lCliEsp
					TRB1->( dbSkip() )
					Loop
				Endif
			Endif
			
			
			//Verifica se foi informado vencimento generico no cab. do lote.       
			
			dVenc := cTod('')			
			If !Empty(M->BTF_VENCTO)
				dVenc := M->BTF_VENCTO
			Endif			
			
			//Calcula a data de vencimento da fatura...			
			If Empty(dVenc)
				If BA0->BA0_VENCUS > 0
					dVenc := PL628Venc(BA0->BA0_VENCUS,cMes,cAno,BA0->BA0_TIPCUS)
				Else
					dVenc := cTod('')
				Endif
			Endif
			
			
			//Alimenta o array com os valores de cada operadora...                 
			
			If lCliEsp .and. cTipAgl == '1'
				nPos := Ascan(aValOpe, {|x| x[13] == cEmp})
				
			Elseif lCliEsp .and. cTipAgl == '2'
				nPos := Ascan(aValOpe, {|x| x[08] == cCodCli .and. x[9] == cCodLoj})
				
			Else
				nPos := Ascan(aValOpe, {|x| x[1] == cOpe .and. x[13] ==  '' })
			Endif
			
			If lCliEsp
				SA1->( dbSetorder(01) )
				SA1->( dbSeek(xFilial("SA1")+cCodCli+cCodLoj) )
				cNaturez := SA1->A1_NATUREZ
			Endif
			
			If nPos == 0
				Aadd( aValOpe, {cOpe,;						// Operadora origem
				BA0->BA0_NOMINT,;							// Nome da operadora origem
				Round(TRB1->BDH_VLRCOP,2),;					// Custo Operacional Servicos Medicos
				Round(TRB1->BDH_VLRTAX,2),;					// Valor da taxa administrativa
				{TRB1->R_E_C_N_O_},;						// Recno do arquivo BDH
				Iif((!Empty(BA0->BA0_CODCLI)  .AND.;
				!Empty(BA0->BA0_VENCTO)),.T.,.F.),;   		// flag que permite selecao no browse
				1,;											// Intercambio
				cCodCli,;									// Codigo do cliente
				cCodLoj,;									// Loja do cliente
				dVenc,;										// Vencimento
				{},;										//
				Round(TRB1->BDH_VLRCP2,2),;					// Custo Operacional Servicos Acessorios
				Iif(lCliEsp,TRB1->BDH_EMPORI,''),;			// Empresa origem, para controle de clientes especificos
				cNaturez,;                                 	// Natureza
				Round(TRB1->BDH_VLRCP3,2),;					// Custo Operacional Outros Servicos
				Round(TRB1->BDH_VLRCP4,2),;
				Round(TRB1->BDH_VLRCP5,2),;
				Round(TRB1->BDH_VLRCP6,2),;
				Round(TRB1->BDH_VLRCP7,2),;
				Round(TRB1->BDH_VLRCP8,2),;
				Round(TRB1->BDH_VLRCP9,2),;
				Round(TRB1->BDH_VLRCPA,2),;
				Round(TRB1->BDH_VLRCPB,2),;
				Round(TRB1->BDH_VLRCPC,2),;
				0,;											// Outros Debitos
				0,;											// Outros Creditos
				BA0->BA0_TIPPAG,;	// Tipo de pagamento
				BA0->BA0_PORTAD,;	// Portador
				BA0->BA0_AGEDEP,;	// Agencia do portador
				BA0->BA0_CTACOR,;	// Conta do portador
				BA0->BA0_BCOCLI,;	// Banco do cliente
				BA0->BA0_AGECLI,;	// Agencia do cliente
				BA0->BA0_CTACLI,;	// Conta do cliente
				TRB1->BDH_VLRT11,;	
				TRB1->BDH_VLRT12,;
				TRB1->BDH_VLRT13,;
				TRB1->BDH_VLRT14,;
				TRB1->BDH_VLRT15,;
				TRB1->BDH_VLRT16,;
				TRB1->BDH_VLRT17,;
				TRB1->BDH_VLRT18,;
				TRB1->BDH_VLRT19,;
				TRB1->BDH_VLRT1A,;
				TRB1->BDH_VLRT1B,;
				TRB1->BDH_VLRT1C})
				
				nPos := Len(aValOpe)
			Else
				aValOpe[nPos][03] += Round(TRB1->BDH_VLRCOP,2)
				aValOpe[nPos][04] += Round(TRB1->BDH_VLRTAX,2)
				aValOpe[nPos][07] += 1
				aValOpe[nPos][12] += Round(TRB1->BDH_VLRCP2,2)				
				aValOpe[nPos][15] += Round(TRB1->BDH_VLRCP3,2)				
				aValOpe[nPos][16] += Round(TRB1->BDH_VLRCP4,2)
				aValOpe[nPos][17] += Round(TRB1->BDH_VLRCP5,2)
				aValOpe[nPos][18] += Round(TRB1->BDH_VLRCP6,2)
				aValOpe[nPos][19] += Round(TRB1->BDH_VLRCP7,2)
				aValOpe[nPos][20] += Round(TRB1->BDH_VLRCP8,2)
				aValOpe[nPos][21] += Round(TRB1->BDH_VLRCP9,2)
				aValOpe[nPos][22] += Round(TRB1->BDH_VLRCPA,2)
				aValOpe[nPos][23] += Round(TRB1->BDH_VLRCPB,2)
				aValOpe[nPos][24] += Round(TRB1->BDH_VLRCPC,2)				
				aValOpe[nPos][34] += Round(TRB1->BDH_VLRT11,2)
				aValOpe[nPos][35] += Round(TRB1->BDH_VLRT12,2)
				aValOpe[nPos][36] += Round(TRB1->BDH_VLRT13,2)
				aValOpe[nPos][37] += Round(TRB1->BDH_VLRT14,2)
				aValOpe[nPos][38] += Round(TRB1->BDH_VLRT15,2)
				aValOpe[nPos][39] += Round(TRB1->BDH_VLRT16,2)
				aValOpe[nPos][40] += Round(TRB1->BDH_VLRT17,2)
				aValOpe[nPos][41] += Round(TRB1->BDH_VLRT18,2)
				aValOpe[nPos][42] += Round(TRB1->BDH_VLRT19,2)
				aValOpe[nPos][43] += Round(TRB1->BDH_VLRT1A,2)
				aValOpe[nPos][44] += Round(TRB1->BDH_VLRT1B,2)
				aValOpe[nPos][45] += Round(TRB1->BDH_VLRT1C,2)				
				aadd(aValOpe[nPos][5],TRB1->R_E_C_N_O_)
			Endif
			
			
			//Posiciona o usuario...                                               
			
			BA1->( dbSetorder(2) )
			BA1->( dbSeek(xFilial("BA1")+TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG)) )
			
			
			//Chave usada para pesquisar titulo no na gracao do mesmo...           
			
			cChave := TRB1->(BDH_CODINT+BDH_CODEMP)
			
			//Localiza plano de saude..           
			
			If !Empty(BA1->BA1_CODPLA)
				cPlano  := BA1->BA1_CODPLA 
				cVersao := BA1->BA1_VERSAO 
			Else
				cPlano  := BA3->BA3_CODPLA 
				cVersao := BA3->BA3_VERSAO 
			Endif 				 
			BI3->(DbSeek(xFilial('BI3')+PLSINTPAD()+cPlano+cVersao) )
			cProduto:= BI3->BI3_CODSB1
			cTes:= BI3->BI3_CODTES                      
			
			
			//Alimenta a composicao de cobranca(BM1) para valor do CO Servicos medicos |
			
			If TRB1->BDH_VLRCOP > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCOP,2),;
				"104",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;//21} ) 
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40       
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				  
			Endif
			
			
			//Alimenta a composicao de cobranca(BM1) para valor das taxas...           |
			
			If TRB1->BDH_VLRTAX > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRTAX,2),;
				"117",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40            
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
				
			Endif
			
			
			//Alimenta a composicao de cobranca(BM1) para valor do CO Servicos Acessorios|
			
			If TRB1->BDH_VLRCP2 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCP2,2),;
				"127",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
			
			
			//Alimenta a composicao de cobranca(BM1) para valor do CO de outros servicos |
			
			If TRB1->BDH_VLRCP3 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCP3,2),;
				"134",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40               
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
				
				
			Endif
			
			If TRB1->BDH_VLRCP4 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCP4,2),;
				"137",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40           
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
			
			If TRB1->BDH_VLRCP5 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCP5,2),;
				"138",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40    
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
			
			If TRB1->BDH_VLRCP6 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCP6,2),;
				"139",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40         
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
			
			If TRB1->BDH_VLRCP7 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCP7,2),;
				"140",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40        
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
			
			If TRB1->BDH_VLRCP8 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCP8,2),;
				"141",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40         
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif          
			
			If TRB1->BDH_VLRCP9 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCP9,2),;
				"142",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif        
			
			If TRB1->BDH_VLRCPA > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCPA,2),;
				"143",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif   
			
			If TRB1->BDH_VLRCPB > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCPB,2),;
				"144",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif                    
			
			If TRB1->BDH_VLRCPC > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRCPC,2),;
				"145",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40       
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
			
			// Trata campos da taxa administrativa desmembrada em atos.
			If TRB1->BDH_VLRT11 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT11,2),;
				"156",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
								
			Endif
			
			If TRB1->BDH_VLRT12 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT12,2),;
				"157",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
						
			If TRB1->BDH_VLRT13 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT13,2),;
				"158",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif	
			
			If TRB1->BDH_VLRT14 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT14,2),;
				"159",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif

			If TRB1->BDH_VLRT15 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT15,2),;
				"160",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
					
			If TRB1->BDH_VLRT16 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT16,2),;
				"161",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
					nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
					
			If TRB1->BDH_VLRT17 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT17,2),;
				"162",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif

			If TRB1->BDH_VLRT18 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT18,2),;
				"163",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
					
			If TRB1->BDH_VLRT19 > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT19,2),;
				"164",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
					
			If TRB1->BDH_VLRT1A > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT1A,2),;
				"165",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif																							
			
			If TRB1->BDH_VLRT1B > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT1B,2),;
				"166",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif

			If TRB1->BDH_VLRT1C > 0
				Aadd(aValope[nPos][11],{"1",;
				Round(TRB1->BDH_VLRT1C,2),;
				"167",;
				'',;
				'',;
				'',;
				TRB1->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
				BA1->BA1_NOMUSR,;
				.T.,;
				BA1->BA1_SEXO,;
				BA1->BA1_GRAUPA,;
				'',;
				'',;
				'',;
				BA1->BA1_TIPUSU,;
				'',;
				'',;
				0 ,;
				StrZero(1,4),;
				0,;
				0,;
				'',;//22
				0  ,;//23
				0  ,;//24
				0  ,;//25
				0,;  //26
				TRB1->R_E_C_N_O_,;  //27   recno
				0,;  //28
				0,;  //29
				'',;  //30
				'',;  //31
				0,;  //32
				0,;  //33
				'',;  //34
				'',;  //35/
				'',;  //36/
				cProduto,;  //37
				cTes,;  //38
				0,;  //39
				0,;  //40
				nil,;  //41
				nil,;  //42
				nil,;  //43
				nil,; //44
				nil,;  //45
				nil,;  //46
				nil,;  //47
				nil,;  //48
				nil,;  //49
				nil,;  //50
				nil,;  //51
				nil,;  //52
				BA3->(RECNO())})  //53
				
			Endif
									
			TRB1->( dbSkip() )
		Enddo
	Enddo
Endif



//Apura o debito/credito para operadoras...                            

If M->BTF_TIPCOB $ '4, 9'   
	cSQL := "SELECT BSQ_CODINT, BSQ_TIPO, BSQ_USUARI,BSQ_VALOR,BSQ_CODLAN, BSP_DESCRI,BSP_TIPSER, BSP_CODLAN, BSQ_CODSEQ, "+cNameBSQ+".R_E_C_N_O_ FROM "+cNameBSQ+","+cNameBSP+" WHERE "
	cSQL += "BSQ_FILIAL = '"+xFilial("BSQ")+"' AND "
	
	//Apenas para outras operadoras...                                     
	
	cSQL += "BSQ_CODINT <> '"+M->BTF_CODOPE+"' AND "	
	cSql += "BSQ_CONEMP = ' '	AND "
	cSql += "BSQ_VERCON = ' '	AND "
	cSql += "BSQ_CONEMP = ' '	AND "
	cSql += "BSQ_VERCON = ' '	AND "
	cSql += "BSQ_SUBCON = ' '	AND "
	cSql += "BSQ_VERSUB = ' '	AND "
	cSQL += "BSQ_MATRIC = ' ' AND "
	cSql += "BSQ_NUMCOB = ' ' AND "
	cSQL += "BSQ_ANO 	= '"+cAno+"' AND "
	cSQL += "BSQ_MES 	= '"+cMes+"' AND "
	
	cSQL += cNameBSQ+".D_E_L_E_T_ = ' ' AND "
	cSQL += "BSP_FILIAL = '"+xFilial("BSP")+"' AND "
	cSQL += "BSP_CODSER = BSQ_CODLAN    AND "
	
	cSQL += cNameBSP+".D_E_L_E_T_ = ' ' "
	cSQL += "ORDER BY BSQ_CODINT "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "PLSDC", .F., .T.)
	
	PLSDC->( dbGotop() )
	    
	PLSDC->( dbGotop() )
	While !PLSDC->( Eof() )
		
		//Variaveis agrupadoras... controle do loop...                         
		
		cOpe 	:= PLSDC->BSQ_CODINT
		cChave  := M->BTF_CODOPE
		
		//Posiciona a operadora...                                             
		
		BAO->( dbSetorder(01) )
		BA0->( dbSeek(xFilial("BA0")+cOpe) ) 
		
		
		//Obtem a natureza para geracao do titulo...   
		cNaturez := BA0->BA0_NATURE		

	   	lCliEsp := .F.
		lAglut	:= .F.
		cCodCli := BA0->BA0_CODCLI
		cCodLoj := BA0->BA0_LOJCLI	

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+cCodCli+cCodLoj))
		
		
		//Inicia o processamento...                 
				
		While ! PLSDC->( Eof() ) .and. PLSDC->BSQ_CODINT == cOpe
			
			
			//Verifica se foi informado vencimento generico no cab. do lote.       
					
			dVenc := cTod('')			
			If !Empty(M->BTF_VENCTO)
				dVenc := M->BTF_VENCTO
			Endif
			
			//Calcula a data de vencimento da fatura... 					
			If Empty(dVenc)	
				If BA0->BA0_VENCTO > 0
					dVenc := PL628Venc(BA0->BA0_VENCTO,cMes,cAno,BA0->BA0_TIPCUS)
				Else
					dVenc := cTod('')
				Endif
			Endif

			nPos := Ascan(aValOpe, {|x| x[1] == cOpe .and. Alltrim(x[13]) ==  '' })
			If nPos == 0
				Aadd( aValOpe, {cOpe,;									// Operadora origem
							BA0->BA0_NOMINT,;							// Nome da operadora origem
							0,;											// Custo Operacional Servicos Medicos
							0,;											// Valor da taxa administrativa
							{0},;										// Recno do arquivo BDH
							Iif((!Empty(BA0->BA0_CODCLI)  .AND.;
							      !Empty(BA0->BA0_VENCTO)),.T.,.F.),;	// flag que permite selecao no browse
							1,;											// Intercambio
							cCodCli,;									// Codigo do cliente
							cCodLoj,;									// Loja do cliente
							dVenc,;										// Vencimento
							{},;										//
							0,;											// Custo Operacional Servicos Acessorios  
							'',;										// Empresa origem, para controle de clientes especificos
							cNaturez,;                                 	// Natureza
							0,;											// Custo Operacional Outros Servicos
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							Iif(PLSDC->BSQ_TIPO == '1', PLSDC->BSQ_VALOR,0),;
							Iif(PLSDC->BSQ_TIPO == '2', PLSDC->BSQ_VALOR,0),;
							BA0->BA0_TIPPAG,;	// Tipo de pagamento 28
							BA0->BA0_PORTAD,;	// Portador
							BA0->BA0_AGEDEP,;	// Agencia do portador
							BA0->BA0_CTACOR,;	// Conta do portador
							BA0->BA0_BCOCLI,;	// Banco do cliente
							BA0->BA0_AGECLI,;	// Agencia do cliente
							BA0->BA0_CTACLI,;	// Conta do cliente
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0})
				nPos := Len(aValOpe)
			Else
				If PLSDC->BSQ_TIPO == '1'
					aValOpe[nPos][25] += PLSDC->BSQ_VALOR
				Else
					aValOpe[nPos][26] += PLSDC->BSQ_VALOR			
				Endif
			Endif
			
			
			//Alimenta a composicao de cobranca(BM1) para valor do CO Servicos medicos |
			
			Aadd(aValope[nPos][11],{PLSDC->BSQ_TIPO,;
								 PLSDC->BSQ_VALOR,;
								 PLSDC->BSP_CODLAN,;
								 '',;
								 '',;
								 PLSDC->BSQ_CODINT,;
								 '',;
								 'INTERCAMBIO EVENTUAL',;
								 .T.,;
								 '',;
								 '',;
								 '',;
								 '',;
								 '',;
								 '',;
								 '',;
								 '',;
								 0 ,;
								 StrZero(1,4),;
								 0,;
								 0,;
								'',;//22
								0  ,;//23
								0  ,;//24
								0  ,;//25
								0,;  //26  
								PLSDC->R_E_C_N_O_,;  //27  
								0,;  //28
								0,;  //29
								'',;  //30
								'',;  //31
								0,;  //32
								0,;  //33
								'',;  //34
								'',;  //35/
								'',;  //36/
								cProduto,;  //37
								cTes,;  //38
								0,;  //39
								0})  //40
										

								 
        	PLSDC->( dbSkip() )
        Enddo
   	Enddo                   
   	// Fecha area de trabalho temporario.
	PLSDC->( dbCloseArea() )
	
	// Valida o matriz a fim de nao permitir valores zerados.
	For nCnt := 1 To Len(aValope)
		If aValOpe[nCnt][25] - aValOpe[nCnt][26] > 0
			aValope[nCnt][6] := .T.
		Else
			aValope[nCnt][6] := .F.
		Endif
	Next
Endif

If Len(aValOpe) == 0
	Help("",1,"REGNOIS")
	BA3->(DbClearFilter())
	BA3->(RetIndex("BA3"))       
    
	TRB1->( dbClosearea() )
	Return({.F.,{}})
Endif


//Ordena o array por  ordem de operadora!                              

Asort(aValOpe,,,{|x, y| x[1] < y[1]})


//Tecla de atalho para trocar o cliente...                             

SetKey(VK_F10,{||A628Clie(@aValOpe, oBrwOpe)}) 


//Monta tela pra selecao das operadoras a serem faturadas...           
if !lAuto
	DEFINE MSDIALOG oDlg TITLE STR0032+M->BTF_ANOINI+" / "+M->BTF_MESINI FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault() //"Competencia "

	@ 015, 005 GROUP oGrupo1 TO 032,150 OF oDlg  COLOR CLR_HBLUE PIXEL
	@ 020, 010 Say oSay PROMPT STR0033 SIZE 200, 006 OF oGrupo1 PIXEL COLOR CLR_HBLUE //"MARQUE AS OPERADORAS A SEREM FATURADAS"

	@ 015, 220 GROUP oGrupo2 TO 032,350 OF oDlg  COLOR CLR_HBLUE PIXEL
	@ 020, 225 Say oSay PROMPT STR0034 SIZE 200, 006 OF oGrupo2 PIXEL COLOR CLR_HBLUE //"F10 - PARA MUDAR O CLIENTE E O VENCIMENTO"

	oBrwOpe := TcBrowse():New( 035, 000, 356, 165,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )             
	oBrwOpe:lHScroll 	:= .t.
	oBrwOpe:lVScroll 	:= .t.
	oBrwOpe:AddColumn(TcColumn():New(" ",{ || IF(aValOpe[oBrwOpe:nAt,6],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
	         "@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))     
	
	oBrwOpe:AddColumn(TcColumn():New(STR0035,{ || OemToAnsi(aValOpe[oBrwOpe:nAt,1]) },; //"Operadora"
	         "@!",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))     

	oBrwOpe:AddColumn(TcColumn():New(STR0036,{ || OemToAnsi(aValOpe[oBrwOpe:nAt,2]) },; //"Descricao"
	         "@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))     
	
	oBrwOpe:AddColumn(TcColumn():New(STR0037,{ || OemToAnsi(Transform(aValOpe[oBrwOpe:nAt,7],"@E 99999")) },; //"Eventos"
	         "@!",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))                                                    

	oBrwOpe:AddColumn(TcColumn():New(STR0038,{ || OemToAnsi(Transform(	aValOpe[oBrwOpe:nAt,03]+aValOpe[oBrwOpe:nAt,16]+; //"CO Serv. Med."
																				aValOpe[oBrwOpe:nAt,17]+aValOpe[oBrwOpe:nAt,18]+;
																				aValOpe[oBrwOpe:nAt,19]+aValOpe[oBrwOpe:nAt,20]+;
																				aValOpe[oBrwOpe:nAt,21]+aValOpe[oBrwOpe:nAt,24],"@E 999,999,999.99")) },;
																		         nil,nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil))     

	oBrwOpe:AddColumn(TcColumn():New(STR0039,{ || OemToAnsi(Transform(	aValOpe[oBrwOpe:nAt,12]+aValOpe[oBrwOpe:nAt,22]+; //"CO Serv. Ace."
																				aValOpe[oBrwOpe:nAt,23],"@E 999,999,999.99")) },;
																		         nil,nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil))     

	oBrwOpe:AddColumn(TcColumn():New(STR0040,{ || OemToAnsi(Transform(aValOpe[oBrwOpe:nAt,15],"@E 999,999,999.99")) },; //"CO Outros Serv."
	         nil,nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil))     
	
	oBrwOpe:AddColumn(TcColumn():New(STR0041,{ || OemToAnsi(Transform(aValOpe[oBrwOpe:nAt,04]+aValOpe[oBrwOpe:nAt,34]+; //"Taxas Adm."
																			aValOpe[oBrwOpe:nAt,35]+aValOpe[oBrwOpe:nAt,36]+;
																			aValOpe[oBrwOpe:nAt,37]+aValOpe[oBrwOpe:nAt,38]+;
																			aValOpe[oBrwOpe:nAt,39]+aValOpe[oBrwOpe:nAt,40]+;
																			aValOpe[oBrwOpe:nAt,41]+aValOpe[oBrwOpe:nAt,42]+;
																			aValOpe[oBrwOpe:nAt,43]+aValOpe[oBrwOpe:nAt,44]+;
																			aValOpe[oBrwOpe:nAt,45],"@E 999,999,999.99"))},;
	         nil,nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil))     

	oBrwOpe:AddColumn(TcColumn():New(STR0042,{ || OemToAnsi(Transform(aValOpe[oBrwOpe:nAt,25],"@E 999,999,999.99"))},; //"Outros Debitos"
	         nil,nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil))     
	
	oBrwOpe:AddColumn(TcColumn():New(STR0043,{ || OemToAnsi(Transform(aValOpe[oBrwOpe:nAt,26],"@E 999,999,999.99"))},; //"Outros Creditos"
	         nil,nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil))     
	

	//Variavel contem o total do titulo por operadora...                   
	
	//nTotTit := 

	oBrwOpe:AddColumn(TcColumn():New(STR0044,{ || OemToAnsi(Transform((aValOpe[oBrwOpe:nAt,03]+aValOpe[oBrwOpe:nAt,04]+; //"Total  "
				aValOpe[oBrwOpe:nAt,12]+aValOpe[oBrwOpe:nAt,15]+;
				aValOpe[oBrwOpe:nAt,16]+aValOpe[oBrwOpe:nAt,17]+;
				aValOpe[oBrwOpe:nAt,18]+aValOpe[oBrwOpe:nAt,19]+;
				aValOpe[oBrwOpe:nAt,20]+aValOpe[oBrwOpe:nAt,21]+;
				aValOpe[oBrwOpe:nAt,22]+aValOpe[oBrwOpe:nAt,23]+;
				aValOpe[oBrwOpe:nAt,24]+aValOpe[oBrwOpe:nAt,25]+;
				Iif(M->BTF_TIPCOB<>'4',aValOpe[oBrwOpe:nAt,26],(aValOpe[oBrwOpe:nAt,26]*-1))+;
				aValOpe[oBrwOpe:nAt,34]+aValOpe[oBrwOpe:nAt,35]+;
				aValOpe[oBrwOpe:nAt,36]+aValOpe[oBrwOpe:nAt,37]+;
				aValOpe[oBrwOpe:nAt,38]+aValOpe[oBrwOpe:nAt,39]+;
				aValOpe[oBrwOpe:nAt,40]+aValOpe[oBrwOpe:nAt,41]+;
				aValOpe[oBrwOpe:nAt,42]+aValOpe[oBrwOpe:nAt,43]+;
				aValOpe[oBrwOpe:nAt,44]+aValOpe[oBrwOpe:nAt,45]),"@E 999,999,999.99"))},;
			nil,nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil))     

	oBrwOpe:AddColumn(TcColumn():New(STR0045,{ || aValOpe[oBrwOpe:nAt,10]},; //"Vencto."
	         nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))              
	
	oBrwOpe:AddColumn(TcColumn():New(STR0046,{ || aValOpe[oBrwOpe:nAt,08]},; //"Cliente"
	         nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))                       
	
	oBrwOpe:AddColumn(TcColumn():New(STR0047,{ || aValOpe[oBrwOpe:nAt,09]},; //"Loja"
	         nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))                                

	oBrwOpe:AddColumn(TcColumn():New(STR0046,{ || Posicione("SA1",1,xFilial("SA1")+aValOpe[oBrwOpe:nAt,08]+; //"Cliente"
												    aValOpe[oBrwOpe:nAt,09],"A1_NOME")},;
											        nil,nil,nil,nil,700,.F.,.F.,nil,nil,nil,.F.,nil))                       										                          
	oBrwOpe:SetArray(aValOpe)         
	oBrwOpe:bLDblClick := { || A628MrkVld( aValOpe, oBrwOpe ) }


	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})
endif			

//Desfaz filtro...                                                     

BA3->(DbClearFilter())
BA3->(RetIndex("BA3"))       


//Reseta tecla de atalho...                                            

SET KEY VK_F10 TO

TRB1->( dbClosearea() )
Return({lRet,aValOpe,cChave})

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Pl628Exc
Exclui itens relacionados a cobranca 

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function Pl628Exc(cCodOpe, cNumero, cInterC)

Local cSql

//Exclui Detalhes...
cSql := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("BTO") + " "
cSql += "WHERE BTO_FILIAL = '" + xFilial("BTO") + "' "
cSql += "AND   BTO_CODOPE = '" + cCodOpe + "' "
cSql += "AND   BTO_NUMERO = '" + cNumero + "' "
cSql += "AND D_E_L_E_T_ = ' '"
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "SELEBTO", .F., .T.)

While ! SELEBTO->(Eof())
	BTO->(DbGoTo(SELEBTO->RECNO))
	If BTO->BTO_REEANE == "1"
		cQryBD5 := "SELECT R_E_C_N_O_ REGISTRO FROM "+ RetSqlName('BD5')
		cQryBD5 += "WHERE BD5_FILIAL = '"+xFilial("BD5")+"' AND " 
		cQryBD5 += "BD5_ENV507 = '1' AND " 
		cQryBD5 += "BD5_PRE507 = '"+BTO->BTO_PREFIX+"' AND " 
		cQryBD5 += "BD5_NUM507 = '"+BTO->BTO_NUMTIT+"' AND  " 
		cQryBD5 += "BD5_PAR507 = '"+BTO->BTO_PARCEL+"' AND  " 
		cQryBD5 += "BD5_TIP507 = '"+BTO->BTO_TIPTIT+"' AND  " 
		cQryBD5 += "D_E_L_E_T_ = ' ' " 
		cQryBD5 := ChangeQuery( cQryBD5 )
		IIF(Select("QRYBD5")>0,QRYBD5->(DbCloseArea()),Nil)
		DbUseArea(.T., "TopConn", TCGenQry(,,cQryBD5), "QRYBD5", .F., .F.)
        QRYBD5->(DbGoTop())
		While QRYBD5->(!EOF())
			BD5->(DbSelectArea("BD5"))
			BD5->(DbGoto(QRYBD5->REGISTRO))
			BD5->(RecLock("BD5", .F. ))
			BD5->BD5_ENV507 := '0'
			BD5->BD5_PRE507 := ""
			BD5->BD5_NUM507 := ""
			BD5->BD5_PAR507 := ""
			BD5->BD5_TIP507 := ""
			BD5->(MsUnlock())
			QRYBD5->(DbSkip())
		End Do
		BD5->(DbCloseArea())
		If Select("QRYBD5") > 0
			QRYBD5->(DbCloseArea())
		Endif
	Endif

	cSql := " SELECT R_E_C_N_O_ RECNO FROM " + retSqlName("BCI")
	cSql += " WHERE "
	cSql += " BCI_FILIAL = '" + xFilial("BCI") + "' "
	cSql += " AND BCI_LOTEDI = 'BTO|" + BTO->BTO_NUMERO + "' "
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBBCI", .F., .T.)
	while !TRBBCI->(Eof())
		BCI->(DBGoTo(TRBBCI->RECNO))
		BCI->(RecLock("BCI", .F.))
		BCI->BCI_LOTEDI := ""
		BCI->(MsUnLock())
		TRBBCI->(DBSkip())
	enddo
	TRBBCI->(DBCloseArea())	
	
	BTO->(RecLock("BTO",.F.))
		BTO->(DbDelete())
	BTO->(MsUnLock())
	SELEBTO->(DbSkip())
Enddo
SELEBTO->(DbCloseArea())


//Exclui Criticas...                                                   

cSql := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("BTG") + " "
cSql += "WHERE BTG_FILIAL = '" + xFilial("BTG") + "' "
cSql += "AND BTG_CODOPE = '" + cCodOpe + "' "
cSql += "AND BTG_NUMERO = '" + cNumero + "' "
cSql += "AND D_E_L_E_T_ = ' '"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "SELEBTG", .F., .T.)


While !SELEBTG->( Eof() )
	BTG->(DbGoTo(SELEBTG->RECNO))
	BTG->(RecLock("BTG",.F.))
		BTG->(DbDelete())
	BTG->(MsUnLock())
	SELEBTG->(DbSkip())
Enddo
SELEBTG->(DbCloseArea())


Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Cr628FolCri
Monta Tela de critica para os lotes de cobranca

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function Cr628FolCri(nOpc)

If nOpc <> K_Incluir
		
		//Objeto com as criticas, caso tenha...                                
		
		if lDadCri[1] == 0
			bFilter := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("BTG_OPEORI",aHeader)]==cOpeOri .and.;
											  aCols[nLine,GdFieldPos("BTG_SEQUEN",aHeader)]==cSequen }
			oGetCri1:= TPLSBrw():New(001,001,aPosObj[2][3]-5,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCri1   ,aDadCri1 ,.F.      ,"BTG" ,K_Visualizar,STR0050,nil,nil,nil,,,,bFilter) //"Criticas da Operadora"
			oGetCri1:oPai := oBrwBTO
			oGetCri1:aOrigem  := {"BTO_OPEORI","BTO_SEQUEN"}
			oGetCri1:aRelac   := {"BTG_OPEORI","BTG_SEQUEN"}
		Else
			@ 005, 006 Say oSayCri1 PROMPT STR0051 SIZE 150, 006 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE //"Nao foram encontradas criticas para este nivel"
		Endif                             
		
		
		//Objeto com os titulos gerados, caso tenha...                         
		
		bFilter := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("E1_PREFIXO",aHeader)]==cPrefix .and.;
									      aCols[nLine,GdFieldPos("E1_NUM"    ,aHeader)]==cNumTit .and.;
									      aCols[nLine,GdFieldPos("E1_PARCELA",aHeader)]==cParcel }
		oGetSE1G:= TPLSBrw():New(005,001,aPosObj[2][3]-5,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[3],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabSE1G  ,aDadSE1G,.F.      ,"SE1" ,K_Visualizar,STR0019,nil,nil,nil,,,,bFilter) //"Titulos Gerados"
		oGetSE1G:oPai := oBrwBTO
		oGetSE1G:aOrigem  := {"BTO_PREFIX","BTO_NUMTIT","BTO_PARCEL"}
		oGetSE1G:aRelac   := {"E1_PREFIXO","E1__NUM"   ,"E1_PARCELA"}
		
		
		//Objeto com os titulos cancelados, caso tenha...                      
		
		bFilter := {|nLine,aCols,aHeader| aCols[nLine,GdFieldPos("BTV_PREFIX",aHeader)]==cPrefix .and.;
									      aCols[nLine,GdFieldPos("BTV_NUM"   ,aHeader)]==cNumTit .and.;
									      aCols[nLine,GdFieldPos("BTV_PARCEL",aHeader)]==cParcel }		
		oGetBTV  := TPLSBrw():New(005,001,aPosObj[2][3]-5,aPosObj[2][4]-15,nil  ,oFolder:aDialogs[04],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBTV   ,aDadBTV ,.F.      ,"BTV" ,K_Visualizar,STR0020,nil,nil,nil,,,,bFilter) //"Titulos Cancelados"
		oGetSE1G:oPai := oBrwBTO
		oGetSE1G:aOrigem  := {"BTO_PREFIX","BTO_NUMTIT","BTO_PARCEL"}
		oGetSE1G:aRelac   := {"BTV_PREFIX","BTV_NUM"   ,"BTV_PARCEL"}
Endif	

Return .T.
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL628DESINT
Atualiza as GETDADOS de acordo com a localidade

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function PL628DESINT()
Return(Posicione("BA0",1,xFilial("BA0")+BTO->BTO_OPEORI,"BA0_NOMINT"))

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Pl628CarSE1
Atualiza as GETDADOS de acordo com a localidade

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function Pl628CarSE1(	aCobranca, nCols, nLido, nBDF_PREFIX, nBDF_NUMTIT, nBDF_PARCEL,;
						nBDF_TIPTIT, nBDF_TIPO, aSE1, cTipo, cNumCob)
Local nHeader
Local nE1_PREFIXO 	:= Ascan(aCabSE1G, { |x| AllTrim(x[2]) = "E1_PREFIXO" })
LOCAL nE1_NUM 		:= Ascan(aCabSE1G, { |x| AllTrim(x[2]) = "E1_NUM" })
LOCAL nE1_PARCELA 	:= Ascan(aCabSE1G, { |x| AllTrim(x[2]) = "E1_PARCELA" })
LOCAL nE1_TIPO 		:= Ascan(aCabSE1G, { |x| AllTrim(x[2]) = "E1_TIPO" })
LOCAL cAlias		:= If(cTipo = "2", "SE1QRY", "SE1")
LOCAL nCnt 			:= 0

SE1->(DbSetOrder(1))
For nCnt := 1 To Len(aCobranca)
	If Ascan(aSE1, { |x| 	x[nE1_PREFIXO] 	= aCobranca[nCnt][nBDF_PREFIX] .And.;
							x[nE1_NUM] 		= aCobranca[nCnt][nBDF_NUMTIT] .And.;
							x[nE1_PARCELA] 	= aCobranca[nCnt][nBDF_PARCEL] .And.;
							x[nE1_TIPO] 	= aCobranca[nCnt][nBDF_TIPTIT] }) = 0
		
		SE1->(DbSeek(xFilial("SE1")  +	aCobranca[nCnt][nBDF_PREFIX] +;
										aCobranca[nCnt][nBDF_NUMTIT] +;
										aCobranca[nCnt][nBDF_PARCEL] +;
										aCobranca[nCnt][nBDF_TIPTIT]))
		nLido ++
		If nLido > nCols
			Aadd(aSE1, AClone(aSE1[1]))
			nCols ++
		Endif
		If SE1->E1_VALOR = SE1->E1_SALDO
			aSE1[nCols][1] := "ENABLE"
		ElseIf SE1->E1_SALDO = 0
			aSE1[nCols][1] := "DISABLE"
		Else
			aSE1[nCols][1] := "BR_AZUL"
		Endif
		For nHeader := 2 To Len(aCABSE1G)
			aSE1[nCols][nHeader] := &(cAlias + "->" + AllTrim(aCabSE1G[nHeader][2]))
		Next
		If cTipo = "2"
			(cAlias)->(DbCloseArea())
		Endif
	Endif
Next

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA628Num
Retorna o proximo numero do lote a partir de uma operadora

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function PLSA628Num(cCodInt)
LOCAL nRet    := 0
LOCAL nOrdBTF := BTF->(IndexOrd())
LOCAL nTam    := Len(BTF->BTF_NUMERO)

BTF->(DbSetOrder(1))

BTF->(DbSeek(xFilial("BTF")+cCodInt+Replicate("9",nTam),.T.))
BTF->(DbSkip(-1))

If BTF->(BTF_FILIAL+BTF_CODOPE) <> xFilial("BTF")+cCodInt
	nRet := StrZero(1,nTam)
Else
	nRet := StrZero(Val(BTF->BTF_NUMERO)+1,nTam)
Endif

BTF->(DbSetOrder(nOrdBTF))

Return(nRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA628SE1
Deleta titulos/comissoes pagas para o lote de cobranca tambem podera deletar um titulo de um lote de cobranca

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function PLSA628SE1(cNumCob,cBBT_PREFIX,cBBT_NUMTIT,cBBT_PARCEL,cBBT_TIPTIT)
LOCAL cFor 		:= "BBT_NUMCOB = '"+cNumCob+"'" 
LOCAL cArea 	:= Alias()
LOCAL aRet		:= {}                                
LOCAL lRet		:= .t.
local lJaCri    := .f.
LOCAL aRegBSQ	:= {}
local aEstorno  := {}
LOCAL nCnt		:= 0
local nI        := 0
local nPos      := 0
LOCAL aCriticas	:= {}
LOCAL aCabec	:= { {STR0052,"@C",20},{STR0053,"@C",30},; //"Prefixo"###"Numero"
					 {STR0054,"@C",20},{STR0055,"@C",20},; //"Parcela"###"Tipo"
					 {STR0014,"@C",250} } //"Critica"

//Selectiona os titulos pertencentes ao lote...                            
cFor := "SELECT * FROM " + RetSqlName("BBT")
cFor += " WHERE BBT_FILIAL = '" + xFilial("BBT") + "' AND BBT_NUMCOB = '"+cNumCob+"' AND "
If cBBT_PREFIX # Nil
	cFor += "BBT_PREFIX = '" + cBBT_PREFIX + "' AND "
	cFor += "BBT_NUMTIT = '" + cBBT_NUMTIT + "' AND "
	cFor += "BBT_PARCEL = '" + cBBT_PARCEL + "' AND "
	cFor += "BBT_TIPTIT = '" + cBBT_TIPTIT + "' AND "
Endif
cFor += "BBT_INTERC = '1' AND "
cFor += "D_E_L_E_T_ = ' '"
cFor += " ORDER BY BBT_PREFIX DESC, BBT_NUMTIT DESC, BBT_PARCEL DESC "

cFor := ChangeQuery(cFor)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFor), "BBTQRY", .F., .T.)

//Analiza baixas e a situacao do titulo, antes de exclui-lo...        
BBTQRY->( dbGotop() )
while ! BBTQRY->(Eof())

	If BBTQRY->BBT_RECPAG == "0"

		SE1->(DbSetOrder(1))

		If SE1->(MsSeek(xFilial("SE1")+BBTQRY->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT)))

			//Executa funcao que analisa a possibilidade de exclusao de uma guia que teve movimentacao financeiro relacionada..
			aRet := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)

			//[1]  - Calendario contabil (.T./.F.)
			//[2]  - Movimentado (.T./.F.)
			//[11] - Indica titulo em carteira (.T./.F.)

			//bloqueio calendario contabil
			if aRet[1]
 				aadd(aCriticas, {SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,"Lote não pode ser excluído, pois existe bloqueio do calendário contábil!"})
                lJaCri := .t.		
			endIf
			
			//Titulo nao esta em carteira, nao pode excluir o lote...										 
			if aRet[11]
				Aadd(aCriticas, {SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,STR0057}) //"Titulo transferido para banco."
                lJaCri := .t.		                
			EndIf

			//movimentacao 
			if aRet[2]
            	
				Aadd(aCriticas, {SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,STR0056})			  //"Titulo baixado."

                //compensacao NCC
				if aRet[13] 
					
					if ! lJaCri
						aadd(aEstorno, SE1->(recno()) )
					endIf

				else
					lJaCri := .t.		
				endIf

			endIf

		Endif

	Endif

BBTQRY->( dbSkip() )
enddo	

//tratamento para retirar compensacao NCC
if len(aEstorno) > 0 .and. msgYesNo('Confirmar o estorno da compensação dos titulos?')

	for nI := 1 to len(aEstorno)
		
		SE1->( msGoTo( aEstorno[nI] ) )

		if PLTITBXCR(.t.)

			nPos := aScan(aCriticas, {|x| x[1] == SE1->E1_PREFIXO .and. x[2] == SE1->E1_NUM .and. x[3] == SE1->E1_PARCELA .and. x[4] == SE1->E1_TIPO } )

			if nPos > 0
				aDel( aCriticas, nPos )
				aSize( aCriticas, len(aCriticas) - 1 )
			endIf

		endIf

	next 

endIf
          
//Encontrado titulos baixados ou que nao estao em carteira...         
if len(aCriticas) > 0
	lRet := .f.
endIf          

if lRet

	BBTQRY->( dbGotop() )
	while !BBTQRY->(Eof())
		
		If BBTQRY->BBT_RECPAG == "0"
			
			If SE1->(msSeek(xFilial("SE1")+BBTQRY->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT)))
				
				//exclui titulos ou nota				
				if ! P629ExcE1()

					disarmTransaction()
					
					aadd(aCriticas, {SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,"Inconsistencia na exclusão do titulo"}) 

					lRet := .f.
					exit
				endIf

			Endif
			
			//Desmarca os registros faturados da tabela de movimentacao...             
			cSql := "SELECT R_E_C_N_O_ AS NREC FROM "+RetSQLName("BDH")+" WHERE "
			cSql += "    BDH_FILIAL = '"+xfilial("BDH")+"' "
			cSql += "AND BDH_PREFIX = '"+BBTQRY->BBT_PREFIX+"' "
			cSql += "AND BDH_NUMTIT = '"+BBTQRY->BBT_NUMTIT+"' "
			cSql += "AND BDH_PARCEL = '"+BBTQRY->BBT_PARCEL+"' "
			cSql += "AND BDH_TIPTIT = '"+BBTQRY->BBT_TIPTIT+"' "
			cSql +=	"AND BDH_INTERC = '1' "                     
			cSql +=	"AND BDH_NUMFAT = '"+cNumCob+"' " 
			cSql += "AND D_E_L_E_T_ = ' ' "

			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TrbBDH", .F., .T.)

			TrbBDH->( dbGotop() )
			While !TrbBDH->(Eof())
				
				BDH->( dbGoto(TrbBDH->NREC) )

				If !BDH->( Eof() )
					
					If ! FindFunction("PLSNOTXBDH") //nova funcao que alem de atualizar o bdh atualiza as notas e eventos. plsmctmd.prw

						BDH->( RecLock("BDH",.F.) )
						BDH->BDH_STATUS := '1'
						BDH->BDH_OPEFAT := ' '
						BDH->BDH_NUMFAT := ' '
						BDH->BDH_PREFIX := ' '
						BDH->BDH_NUMTIT := ' '
						BDH->BDH_PARCEL := ' '
						BDH->BDH_TIPTIT := ' '
						BDH->BDH_INTERC := '1'
						BDH->( MsUnlock() )

					Else
						PLSNOTXBDH("1","","",{"","","",""},.T.)
					Endif   
					
				Endif                                         
				TrbBDH->( dbSkip() )
			Enddo                
			TrbBDH->(DbCloseArea())
			
			//guarda historico BM1
			PL627HSBM1(BBTQRY->BBT_PREFIX, BBTQRY->BBT_NUMTIT, BBTQRY->BBT_PARCEL, BBTQRY->BBT_TIPTIT)

			tcSqlExec(  "UPDATE "+RetSQLName("BM1")+" SET D_E_L_E_T_ = '*' WHERE " +;
						"BM1_FILIAL = '" + BBTQRY->BBT_FILIAL + "' AND " +;
						"BM1_PREFIX = '" + BBTQRY->BBT_PREFIX + "' AND " +;
						"BM1_NUMTIT = '" + BBTQRY->BBT_NUMTIT + "' AND " +;
						"BM1_PARCEL = '" + BBTQRY->BBT_PARCEL + "' AND " +;
						"BM1_TIPTIT = '" + BBTQRY->BBT_TIPTIT + "' AND BM1_INTERC = '1' AND D_E_L_E_T_ = ' '")

		Endif
		
		BSQ->( dbSetorder(03) )
		If BSQ->( dbSeek(xFilial("BSQ")+BBTQRY->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT)) )
			While !BSQ->( Eof() ) .and. BSQ->(BSQ_PREFIX+BSQ_NUMTIT+BSQ_PARCEL+BSQ_TIPTIT) ==;
										BBTQRY->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT)
				Aadd(aRegBSQ, BSQ->(Recno()) )
				BSQ->( dbSkip() )
			Enddo
		Endif

		//Desmarca os lancamentos de debito/credito para operadora...              
		If Len(aRegBSQ) > 0
			For nCnt := 1 To Len(aRegBSQ)
				BSQ->( dbGoto(aRegBSQ[nCnt]) )
				BSQ->( Reclock("BSQ", .F.) )
					BSQ->BSQ_PREFIX := ''
					BSQ->BSQ_NUMTIT := ''
					BSQ->BSQ_PARCEL := ''
					BSQ->BSQ_TIPTIT := ''
					BSQ->BSQ_NUMCOB := ''
				BSQ->( MsUnlock() )
			Next
		Endif
		
		//Deleta registro de complemento do titulo...                              
		BBT->(DbGoto(BBTQRY->R_E_C_N_O_))

		BBT->(RecLock("BBT",.F.))
			BBT->(DbDelete())
		BBT->(MsUnLock())	

	BBTQRY->(DbSkip())
	endDo

endIf

BBTQRY->( dbClosearea() )

if ! lRet

	PLSCRIGEN(aCriticas,aCabec, STR0015,NIL,NIL,NIL,NIL, NIL,NIL,"G",220) //"Verificacao de integridade."

else

	//Pessoa Juridica															 
	tcSqlExec( "UPDATE "+RetSQLName("BQC")+" SET BQC_NUMCOB = ' ', BQC_ULTCOB = ' ' " +;
			" WHERE BQC_FILIAL = '" + xFilial("BQC") + "' AND " +;
			"       BQC_NUMCOB = '"+cNumCob+"' AND D_E_L_E_T_ = ' '")

endIf

if ! Empty(cArea)
	dbSelectArea(cArea)
endIf

return(lRet)
               
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL628Venc
Monta a data do vencimento...

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function PL628Venc(nDia,cMes,cAno,cTipo)
Local nCnt
LOCAL cAnoMesAnt:= PLSDIMAM(cAno,cMes,"0")
LOCAL dEmissao 	:= LastDay(Ctod("01/" + Subs(cAnoMesAnt,5,2) + "/" + Subs(cAnoMesAnt,1,4)))
LOCAL dVencto   := (dEmissao)    //cTod(Strzero(nDia,2)+"/"+cMes+"/"+cAno)

While .T. 

	
	//Trata tipo de vencimento...												 ³
	
	If cTipo $ '1, '		// Dia fixo
		dVencto  := ctod(StrZero(nDia,2)+"/"+cMes+"/"+Subs(cAno,3,2))
		
	Elseif cTipo == '2' // Dias apos a emissao...
		For nCnt := 1 To (nDia)  
			dVencto := (dVencto+1)			
		Next
		
		//Caso a quantidade de dias somados nao sejam suficientes para igualar o   |
		//vencimento a data base atual, o cTipo passa a ser '1' para poder     
		//jogar a data para o proximo mes.                                         |
				
		cTipo := '1'
	Endif	
	
	If dVencto < dDataBase
		cMes := StrZero((Val(cMes)+1),2)
		If cMes > "12"
			cMes := "01"
			cAno := Alltrim(Str((Val(cAno)+1)))
		Endif
		Loop
	Else
	    Exit
	Endif
	
Enddo    

Return(dVencto)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A628Grava
Grava os titulos por operadora...

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Static Function A628Grava(aRet,nCnt,nSeq,aNumTit,cTipCob)
Local i
Local y
LOCAL cMatFam  := ''
LOCAL aRetorno := {}
LOCAL nVLRCOP  := 0
LOCAL nVLRCP2  := 0
LOCAL nVLRCP3  := 0
LOCAL nVLRTAX  := 0
LOCAL nOPEGER  := 0
LOCAL nOPECRI  := 0
LOCAL nNOPEGER := 0
LOCAL nFor     := 0
LOCAL bEmissao := {|| M->BTF_DTEMIS }
LOCAL nValTit  := 0
LOCAL aEventosCb := PLSINPBFQ(PlsIntPad()) 
LOCAL nQtdTit  := 1
LOCAL cPrefix  := ""
LOCAL cNumTit  := ""
LOCAL cTipTit  := ""
LOCAL aVlrCob  := {}
Local cMvPLTIPND := GETMV("MV_PLTIPND")
local cSql := ""
local cAux := ""
local aDadX5 	:= {}
local cNumNew	:= ""
DEFAULT cTipCob := '2' //Padrao de geracao e o modelo antigo 2-Fatura

If Empty(cTipCob)
	cTipCob := '2'
EndIf	

//Se for tipo 3-Ambos, verifico se ha valor de servicos/taxas	e	 
//indico a quantidade de titulos que sera gerada           		

If cTipCob == '3'
	If aRet[2,nCnt,6] .And. (aRet[2,nCnt,3] +aRet[2,nCnt,12]+aRet[2,nCnt,15]+aRet[2,nCnt,16]+aRet[2,nCnt,17]+aRet[2,nCnt,18]+;
	   aRet[2,nCnt,19]+ aRet[2,nCnt,20]+aRet[2,nCnt,21]+aRet[2,nCnt,22]+aRet[2,nCnt,23]+aRet[2,nCnt,24]+aRet[2,nCnt,25]+ ;
	   Iif(M->BTF_TIPCOB<>'4',aRet[2,nCnt,26],(aRet[2,nCnt,26]*-1))) > 0 .And. ;
	   (aRet[2,nCnt,04]+aRet[2,nCnt,34]+aRet[2,nCnt,35]+aRet[2,nCnt,36]+aRet[2,nCnt,37]+aRet[2,nCnt,38]+aRet[2,nCnt,39]+ ;
	   aRet[2,nCnt,40]+aRet[2,nCnt,41]+aRet[2,nCnt,42]+aRet[2,nCnt,43]+aRet[2,nCnt,44]+aRet[2,nCnt,45]) > 0 
		
		nQtdTit := 2 
	EndIf	
ElseIf aRet[2][nCnt][6]
	cPrefix  := aNumTit[1]
	cNumTit  := aNumTit[2]  
	cTipTit  := aNumTit[3]
	nQtdTit  := 1 
EndIf 


//Posiciona a primeira familia... so para constar!!        		

cMatFam := Substr(aRet[2][nCnt][11][1][7],atCodOpe[1],atCodOpe[2])
cMatFam += Substr(aRet[2][nCnt][11][1][7],atCodEmp[1],atCodEmp[2])
cMatFam += Substr(aRet[2][nCnt][11][1][7],atMatric[1],atMatric[2])
BA3->( dbSetorder(01) )
BA3->( dbSeek(xFilial("BA3")+cMatFam) )
                   
For i := 1 to nQtdTit
	If cTipCob == '3' .And. aRet[2,nCnt,6]// Verifico se o item foi selecionado.
		If i == 1
			aNumTit  := PLSA625MDa(M->BTF_ANOINI,M->BTF_MESINI,"1","9",nil,"6")
			cTipTit  := cMvPLTIPND
		Else
			aNumTit  := PLSA625MDa(M->BTF_ANOINI,M->BTF_MESINI,"1","2",nil,"6")
			cTipTit  := aNumTit[3]
		EndIf
		cPrefix  := aNumTit[1]
		cNumTit  := aNumTit[2]
		
	EndIf
	
	//Somente NDC        												
	
	If cTipCob == '1'
		nValTit := 	(aRet[2][nCnt][3]+;
		aRet[2][nCnt][12]+aRet[2][nCnt][15]+;
		aRet[2][nCnt][16]+aRet[2][nCnt][17]+;
		aRet[2][nCnt][18]+aRet[2][nCnt][19]+;
		aRet[2][nCnt][20]+aRet[2][nCnt][21]+;
		aRet[2][nCnt][22]+aRet[2][nCnt][23]+;
		aRet[2][nCnt][24]+aRet[2][nCnt][25]+;
		Iif(M->BTF_TIPCOB<>'4',aRet[2][nCnt][26],(aRet[2][nCnt][26]*-1))+;
		aRet[2][nCnt][34]+aRet[2][nCnt][35]+;
		aRet[2][nCnt][36]+aRet[2][nCnt][37]+;
		aRet[2][nCnt][38]+aRet[2][nCnt][39]+;
		aRet[2][nCnt][40]+aRet[2][nCnt][41]+;
		aRet[2][nCnt][42]+aRet[2][nCnt][43]+;
		aRet[2][nCnt][44]+aRet[2][nCnt][45])
		
		//Somente Fatura                                            		
		
	ElseIf cTipCob == '2'
		nValTit := 	(aRet[2][nCnt][3]+aRet[2][nCnt][04]+;
		aRet[2][nCnt][12]+aRet[2][nCnt][15]+;
		aRet[2][nCnt][16]+aRet[2][nCnt][17]+;
		aRet[2][nCnt][18]+aRet[2][nCnt][19]+;
		aRet[2][nCnt][20]+aRet[2][nCnt][21]+;
		aRet[2][nCnt][22]+aRet[2][nCnt][23]+;
		aRet[2][nCnt][24]+aRet[2][nCnt][25]+;
		Iif(M->BTF_TIPCOB<>'4',aRet[2][nCnt][26],(aRet[2][nCnt][26]*-1))+;
		aRet[2][nCnt][34]+aRet[2][nCnt][35]+;
		aRet[2][nCnt][36]+aRet[2][nCnt][37]+;
		aRet[2][nCnt][38]+aRet[2][nCnt][39]+;
		aRet[2][nCnt][40]+aRet[2][nCnt][41]+;
		aRet[2][nCnt][42]+aRet[2][nCnt][43]+;
		aRet[2][nCnt][44]+aRet[2][nCnt][45])
		
		//Fatura + NDC                                            		
		
	ElseIf cTipCob == '3'
		If i == 1
			nValTit := 	(aRet[2][nCnt][3]+;
			aRet[2][nCnt][12]+aRet[2][nCnt][15]+;
			aRet[2][nCnt][16]+aRet[2][nCnt][17]+;
			aRet[2][nCnt][18]+aRet[2][nCnt][19]+;
			aRet[2][nCnt][20]+aRet[2][nCnt][21]+;
			aRet[2][nCnt][22]+aRet[2][nCnt][23]+;
			aRet[2][nCnt][24]+aRet[2][nCnt][25]+;
			Iif(M->BTF_TIPCOB<>'4',aRet[2][nCnt][26],(aRet[2][nCnt][26]*-1)))
			
		Else
			nValTit := 	aRet[2][nCnt][04]+;
			aRet[2][nCnt][34]+aRet[2][nCnt][35]+;
			aRet[2][nCnt][36]+aRet[2][nCnt][37]+;
			aRet[2][nCnt][38]+aRet[2][nCnt][39]+;
			aRet[2][nCnt][40]+aRet[2][nCnt][41]+;
			aRet[2][nCnt][42]+aRet[2][nCnt][43]+;
			aRet[2][nCnt][44]+aRet[2][nCnt][45]
		EndIf
	EndIf    
	
	//Altera a array de composicao de acordo com o tipo de faturamento
	
	If cTipCob == '1'  
		For nFor := 1 to len(aRet[2][nCnt][11])   
			If aRet[2][nCnt][11][nFor][3] $ '104/127/134/137/138/139/140/141/142/143/144/145'  
				Aadd(aVlrCob,aRet[2][nCnt][11][nFor])
			EndIf
		Next        
	ElseIf cTipCob == '3' 
	    aVlrCob := {}
		
		//Somente eventos de servico                                     	
   			
		If i == 1
			For nFor := 1 to len(aRet[2][nCnt][11])   
				If aRet[2][nCnt][11][nFor][3] $ '104/127/134/137/138/139/140/141/142/143/144/145'  
					Aadd(aVlrCob,aRet[2][nCnt][11][nFor])
				EndIf
			Next        
		
		//Somente eventos de taxa                                     	
   				
		ElseIf i == 2    
			For nFor := 1 to len(aRet[2][nCnt][11])   
				If aRet[2][nCnt][11][nFor][3] $ '117/156/157/158/159/160/161/162/163/164/165/166/167'  
					Aadd(aVlrCob,aRet[2][nCnt][11][nFor])
				EndIf
			Next
		EndIf
	Else
		aVlrCob := aRet[2][nCnt][11]		
	EndIf	
	
	//Grava o titulo no financeiro... Somente se o titulo for selecionado |
	
	If aRet[2][nCnt][6] .and. nValTit > 0
		
		IncProc(STR0058+cNumTit+"  /  " + STR0035 + ": "+aRet[2][nCnt][1]) //"Titulo Numero:" //"Operadora"
		ProcessMessage()
		
		aRetorno := PLGERREC(cPrefix,;	//1-  Prefixo do titulo
		aNumTit[2],;				//2-  Numero do Titulo
		aRet[3] ,;  				//3-  chave
		BTF->BTF_MESINI,;			//4-  Mes da competencia
		BTF->BTF_ANOINI,;			//5-  Ano da competencia
		aRet[2][nCnt][10],;		//6-  Vencimento
		BTF->BTF_NUMERO,;	    	//7-  Numero da cobranca
		nValTit,;  					//8-  Valor do Titulo
		aNumTit[3],;				//9-  Tipo de titulo
		aRet[2][nCnt][8],;			//10- Cliente
		aRet[2][nCnt][9],;			//11- Loja
		"2"	,;						//12- Tipo pessoa Juridica
		aVlrCob,;	  				//13- Composicao da cobranca
		"1"	,;						//14- Nivel
		{} 	,;						//15- Matriculas da familia...
		""	,;						//16- Gratuidade do mes
		.T.	,;						//17- Cobranca aberta ou fechada ( obsoleto )
		0	,;						//18- Acrecimos, complemento do titulo
		.T. ,;						//19- Intercambio sim ou nao
		.F. ,;						//20- Inciste ( obsoleto )
		NIL,;						//21- Banco
		NIL,;						//22- Situacao do titulo 5(E1_SITUACA)
		aRet[2][nCnt][14],;		//23- Natureza
		'1',;						//24- Indica se eh fatura de custo operacionao ou nao - 1 = Somente Custo Operacional, 0 = Outros, ou inclusive com custo!
		'2',;              			//25- Indica que o  titulo foi gerado pelo lote de cobranca de intercambio eventual...
		aRet[2][nCnt][27],;        //26-
		aRet[2][nCnt][28],;        //27-
		aRet[2][nCnt][29],;        //28-
		aRet[2][nCnt][30],;        //29-
		aRet[2][nCnt][31],;        //30-
		aRet[2][nCnt][32],;        //31-
		aRet[2][nCnt][33],;        //32-
		Eval(bEmissao),;			//33- Data de emissao...
		.F.,;                      //34-
		NIL,;	                    //35-
		NIL,;		                //36-
		NIL,; 		                //37-
		NIL,;		                //38-
		BTF->BTF_CODOPE,;          //39-
		aEventosCb,;               //40-
		NIL,;                      // 41-
		NIL,;                      // 42-
		NIL,;                      // 43-
		NIL,;                      // 44-
		NIL,;                      // 45-
		NIL,;                      // 46-
		NIL,;                      // 47-
		NIL,;                      // 48-
		NIL,;                      // 49-
		NIL,;                      // 50-
		NIL,;                      // 51-
		cTipCob,;                  // 52- Tipo de cobranca Ptu A500 / 1-NDC 2-Fatura 3-Ambos
		i)                     	   // 53- Posicao titulo intercambio
	Endif
	
	BTO->( RecLock("BTO",.T.) )
	BTO->BTO_FILIAL := 	xFilial("BTO")
	BTO->BTO_CODOPE := BTF->BTF_CODOPE
	BTO->BTO_OPEORI := aRet[2][nCnt][1]
	BTO->BTO_NUMERO := BTF->BTF_NUMERO
	BTO->BTO_DATGER := BTF->BTF_DATGER
	BTO->BTO_USUOPE := BTF->BTF_USUOPE
	BTO->BTO_HORA   := BTF->BTF_HORA
	BTO->BTO_ANOINI := BTF->BTF_ANOINI
	BTO->BTO_MESINI := BTF->BTF_MESINI
	BTO->BTO_CODINT := BTF->BTF_CODOPE
	BTO->BTO_QTDEVE := aRet[2][nCnt][07]
	If !(cTipCob == "3" .And. i == 2)
		BTO->BTO_VLRCOP := 	aRet[2][nCnt][03]+aRet[2][nCnt][16]+;
		aRet[2][nCnt][17]+aRet[2][nCnt][18]+;
		aRet[2][nCnt][19]+aRet[2][nCnt][20]+;
		aRet[2][nCnt][21]+aRet[2][nCnt][24]
		
		BTO->BTO_VLRCP2 := 	aRet[2][nCnt][12]+aRet[2][nCnt][22]+;
		aRet[2][nCnt][23]
	EndIf
	
	If cTipCob == '3'
		BTO->BTO_TPMOV := '3'
		If i == 1  //NDC
			BTO->BTO_TPCOB := '1' //3
		ElseIf i == 2 //Fatura
			BTO->BTO_TPCOB := '2'
		EndIf
	ElseIf cTipCob == '2'
		BTO->BTO_TPMOV := '2'
		BTO->BTO_TPCOB := '2'
		
	ElseIf cTipCob == '1'
		BTO->BTO_TPMOV := '1'
		BTO->BTO_TPCOB := '1'
	EndIf		

	BTO->BTO_VLRCP3 := aRet[2][nCnt][15]		
	
	//Tipo de cobranca 1-NDC nao registra taxas						
	
	If cTipCob == '1' .Or. (cTipCob == '3' .And. i == 1)
		BTO->BTO_VLRTAX := 0
	Else
		BTO->BTO_VLRTAX := aRet[2][nCnt][04]+aRet[2][nCnt][34]+;
		aRet[2][nCnt][35]+aRet[2][nCnt][36]+;
		aRet[2][nCnt][37]+aRet[2][nCnt][38]+;
		aRet[2][nCnt][39]+aRet[2][nCnt][40]+;
		aRet[2][nCnt][41]+aRet[2][nCnt][42]+;
		aRet[2][nCnt][43]+aRet[2][nCnt][44]+;
		aRet[2][nCnt][45]
	EndIf
	
	If M->BTF_TIPCOB <> '4'
		
		//Tipo de cobranca 1-NDC nao registra taxas						
		
		If cTipCob == '1'
			BTO->BTO_CUSTOT := (aRet[2][nCnt][3]+;
			aRet[2][nCnt][12]+aRet[2][nCnt][15]+;
			aRet[2][nCnt][16]+aRet[2][nCnt][17]+;
			aRet[2][nCnt][18]+aRet[2][nCnt][19]+;
			aRet[2][nCnt][20]+aRet[2][nCnt][21]+;
			aRet[2][nCnt][22]+aRet[2][nCnt][23]+;
			aRet[2][nCnt][24])
			
			//Tipo de cobranca 2-Fatura aglutina tudo  						
			
		ElseIf cTipCob == '2'
			BTO->BTO_CUSTOT := (aRet[2][nCnt][3]+aRet[2][nCnt][04]+;
			aRet[2][nCnt][12]+aRet[2][nCnt][15]+;
			aRet[2][nCnt][16]+aRet[2][nCnt][17]+;
			aRet[2][nCnt][18]+aRet[2][nCnt][19]+;
			aRet[2][nCnt][20]+aRet[2][nCnt][21]+;
			aRet[2][nCnt][22]+aRet[2][nCnt][23]+;
			aRet[2][nCnt][24]+aRet[2][nCnt][34]+;
			aRet[2][nCnt][35]+aRet[2][nCnt][36]+;
			aRet[2][nCnt][37]+aRet[2][nCnt][38]+;
			aRet[2][nCnt][39]+aRet[2][nCnt][40]+;
			aRet[2][nCnt][41]+aRet[2][nCnt][42]+;
			aRet[2][nCnt][43]+aRet[2][nCnt][44]+;
			aRet[2][nCnt][45])
			
			//Tipo de cobranca 3-Ambos separa servicos de taxas				
			
		ElseIf cTipCob == '3'
			If i == 1
				BTO->BTO_CUSTOT := (aRet[2][nCnt][3]+;
				aRet[2][nCnt][12]+aRet[2][nCnt][15]+;
				aRet[2][nCnt][16]+aRet[2][nCnt][17]+;
				aRet[2][nCnt][18]+aRet[2][nCnt][19]+;
				aRet[2][nCnt][20]+aRet[2][nCnt][21]+;
				aRet[2][nCnt][22]+aRet[2][nCnt][23]+;
				aRet[2][nCnt][24])
				
			Else
				BTO->BTO_CUSTOT := (aRet[2][nCnt][04]+aRet[2][nCnt][34]+;
				aRet[2][nCnt][35]+aRet[2][nCnt][36]+;
				aRet[2][nCnt][37]+aRet[2][nCnt][38]+;
				aRet[2][nCnt][39]+aRet[2][nCnt][40]+;
				aRet[2][nCnt][41]+aRet[2][nCnt][42]+;
				aRet[2][nCnt][43]+aRet[2][nCnt][44]+;
				aRet[2][nCnt][45])
			EndIf
			
		EndIf
	Else
		BTO->BTO_CUSTOT := (aRet[2][nCnt][25] - aRet[2][nCnt][26])
	Endif
		
	BTO->BTO_SEQUEN := StrZero(nSeq,3)

	If aRet[2][nCnt][6]
		If Len(aRetorno) == 1
			If aRetorno[1][1]
				BTO->BTO_STATUS := '1'
				
				
				//Grava informacoes financeiras...				                     
				
				BTO->BTO_PREFIX := BBT->BBT_PREFIX
				BTO->BTO_NUMTIT := BBT->BBT_NUMTIT
				BTO->BTO_PARCEL := BBT->BBT_PARCEL
				BTO->BTO_TIPTIT := BBT->BBT_TIPTIT
				
				//Atualiza as variaveis totalizadoras to lote...                       
				
				If !(cTipCob == '3' .And. i == 2)
					nVLRCOP += 	aRet[2][nCnt][03]+aRet[2][nCnt][16]+;
					aRet[2][nCnt][17]+aRet[2][nCnt][18]+;
					aRet[2][nCnt][19]+aRet[2][nCnt][20]+;
					aRet[2][nCnt][21]+aRet[2][nCnt][24]
					
					nVLRCP2 += 	aRet[2][nCnt][12]+aRet[2][nCnt][22]+;
					aRet[2][nCnt][23]
					
					nVLRCP3 += 	aRet[2][nCnt][15]
				EndIf
				
				If cTipCob == '2' .Or. (cTipCob == '3' .And. i == 2)
					nVLRTAX += 	aRet[2][nCnt][04]+aRet[2][nCnt][34]+;
					aRet[2][nCnt][35]+aRet[2][nCnt][36]+;
					aRet[2][nCnt][37]+aRet[2][nCnt][38]+;
					aRet[2][nCnt][39]+aRet[2][nCnt][40]+;
					aRet[2][nCnt][41]+aRet[2][nCnt][42]+;
					aRet[2][nCnt][43]+aRet[2][nCnt][44]+;
					aRet[2][nCnt][45]
				EndIf
				
				If !(cTipCob == '3' .And. i==2)
					nOPEGER += 1
				EndIf
				
				
				//Atualiza a tabela de movimentacoes, marcando os registros ja faturados...³
				
				For y := 1 To Len(aRet[2][nCnt][5])
					BDH->( dbGoto(aRet[2][nCnt][5][y]) )
					If !BDH->( Eof() )
						PLSNOTXBDH('0',aRet[2][nCnt][1],(BTF->BTF_CODOPE+BTF->BTF_NUMERO),{BBT->BBT_PREFIX,BBT->BBT_NUMTIT,BBT->BBT_PARCEL,BBT->BBT_TIPTIT},.T.)
						
						If cAux != BDH->(BDH_SEQPF+BDH_MESFT+BDH_ANOFT)
							cAux := BDH->(BDH_SEQPF+BDH_MESFT+BDH_ANOFT)
							cSql := " UPDATE " + retSqlName("BCI")
							cSql += " SET BCI_LOTEDI = 'BTO|" + BTO->BTO_NUMERO + "'"
							cSql += " WHERE "
							cSql += " BCI_FILIAL = '"+xFilial("BCI")+"'  "
							cSql += " AND D_E_L_E_T_ = ' ' "
							cSql += " AND EXISTS ("
							cSql += " SELECT 1 FROM " + retSqlName("BD6") + " BD6" 
							cSql += " WHERE "
							cSql += " BD6_FILIAL = '"+xFilial("BD6")+"'  "
							cSql += " AND BCI_CODOPE = BD6_CODOPE "
							cSql += " AND BCI_CODLDP = BD6_CODLDP "
							cSql += " AND BCI_CODPEG = BD6_CODPEG "
							cSql += " AND BD6_OPEUSR = '" + BDH->BDH_CODINT + "' "
							cSql += " AND BD6_CODEMP = '" + BDH->BDH_CODEMP + "' "
							cSql += " AND BD6_MATRIC = '" + BDH->BDH_MATRIC + "' "
							cSql += " AND BD6_TIPREG = '" + BDH->BDH_TIPREG + "' "
							cSql += " AND BD6_SEQPF  = '" + BDH->BDH_SEQPF + "' "
							cSql += " AND BD6_ANOPAG = '" + BDH->BDH_ANOFT  + "' "
							cSql += " AND BD6_MESPAG = '" + BDH->BDH_MESFT + "' "
							cSql += " AND BD6.D_E_L_E_T_ = ' ') "
							PLSCOMMIT(cSql)

						Endif	
					Endif
				Next
			Else
				BTO->BTO_STATUS := '2'
				nOPECRI += 1
			Endif
		Elseif Len(aRetorno) > 1
			BTO->BTO_STATUS := '2'
			nOPECRI += 1
		Endif
		
		If BTO->BTO_STATUS == '2'
			
			//Titulo criticado, estorna o SX5.
			aDadX5 := FWGetSX5("BK", cPrefix)

			If len(aDadX5) > 0
				If  StrZero(Val(aDadX5[1][4]),6) == cNumTit
					_nH := PLSAbreSem("PL627X5.SMF")
						cNumNew := Tira1( alltrim(aDadX5[1][4]) )
						cSql := " UPDATE " + RetSqlName("SX5") + " SET "
						cSql += "   X5_DESCRI  = '" + cNumNew + "', X5_DESCSPA = '" + cNumNew + "', X5_DESCENG = '" + cNumNew + "' "
						cSql += " WHERE "
						cSql += "   X5_FILIAL = '" + xFilial("SX5") + "' AND  X5_TABELA  = 'BK'  AND " 
						cSql += "   X5_CHAVE = '"  + cPrefix        + "' AND  D_E_L_E_T_ = ' ' "
						TCSqlExec(cSql)
					PLSFechaSem(_nH,"PL627X5.SMF")
				Endif
			Endif
		Endif
	Else
		BTO->BTO_STATUS := '3'
		nNOPEGER += 1
	Endif
	BTO->( msUnlock() )

Next

If ExistBlock("PL628GR")
	ExecBlock("PL628GR",.F.,.F.)
EndIf

//Atualiza o cabecalho do lote...                                      

BTF->( RecLock("BTF",.F.) )
	BTF->BTF_VLRCOP += nVLRCOP
	BTF->BTF_VLRCP2 += nVLRCP2	
	BTF->BTF_VLRCP3 += nVLRCP3	
	BTF->BTF_VLRTAX += nVLRTAX		
	If M->BTF_TIPCOB <> '4'
		BTF->BTF_CUSTOT += (nVLRCOP+nVLRCP2+nVLRTAX+nVLRCP3)
		// Caso tenha selecionado a opcao 9-Todos, deve somar tambem os debitos/creditos ao final do lote.
		If M->BTF_TIPCOB == '9'
			BTF->BTF_CUSTOT += (aRet[2][nCnt][25] - aRet[2][nCnt][26])
		Endif
	Else
		BTF->BTF_CUSTOT := (aRet[2][nCnt][25] - aRet[2][nCnt][26])
	Endif
	
	BTF->BTF_OPEGER += nOPEGER
	BTF->BTF_OPECRI += nOPECRI
	BTF->BTF_NOSELE += nNOPEGER
BTF->( msUnlock() )


//Atualiza a critica detalhda...                                       

If Len(aRetorno) > 0
	For I := 1 to Len(aRetorno)
		If aRetorno[I][1]
			Loop
		Endif
		BTG->(RecLock("BTG",.T.))
			BTG->BTG_FILIAL := xFilial("BTG")
			BTG->BTG_CODOPE := BTF->BTF_CODOPE
			BTG->BTG_NUMERO := BTF->BTF_NUMERO
			BTG->BTG_CODSEQ := StrZero(I,3)
			BTG->BTG_CODCRI := aRetorno[I,2]
			BTG->BTG_NIVEL  := "1"
			BTG->BTG_DTCRIT := dDataBase
			BTG->BTG_OPEORI := aRet[2][nCnt][1]
			BTG->BTG_SEQUEN := StrZero(nSeq,3)
			
			// Descricao da critica...
			BTG->BTG_DESCRI := aRetorno[I,3]
		BTG->(MsUnLock())
	Next
Endif
			
Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A628Grava
Pinta o campo de status no resumo do faturamento de interc eventual...

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function A628Cor()
LOCAL cRet := "ENABLE"

If BTO->BTO_STATUS == "2"
	cRet := "DISABLE"
	
Elseif BTO->BTO_STATUS == "3"
	cRet := "BR_AZUL"
	
Elseif BTO->BTO_STATUS == "4"
	cRet := "BR_LARANJA"
		
Endif

Return(cRet)
                              

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A628Clie
Telinha chamada para trocar o cliente da operadora no browse de apresentacao dos valores de cada umas

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Static Function A628Clie(aValOpe, oObj)
LOCAL cCodCli 	:= aValOpe[oBrwOpe:nAt,08]
LOCAL cLojCli 	:= aValOpe[oBrwOpe:nAt,09]
LOCAL cNomCli 	:= Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_NOME")
LOCAL dVencto	:= aValOpe[oBrwOpe:nAt,10]
LOCAL nOpca		:= 2
LOCAL oGet1
LOCAL oGet2
LOCAL oGet3
LOCAL oGet4

DEFINE MSDIALOG oDlg1 TITLE STR0059 FROM 015,015 TO 023, 080 OF GetWndDefault() //'Ateracao do cliente'

@ 018, 005 Say oSay1 PROMPT STR0013 SIZE 030, 010 OF oDlg1 PIXEL COLOR CLR_HBLUE //"Codigo"
@ 018, 035 MSGET oGet1 VAR cCodCli Valid(A628Val(cCodCli,@cLojCli,@cNomCli,oDlg1)) F3 "SA1" SIZE 030,010 OF oDlg1 PIXEL 

@ 018, 080 Say oSay1 PROMPT STR0047 SIZE 025, 010 OF oDlg1 PIXEL COLOR CLR_HBLUE //"Loja"
@ 018, 095 MSGET oGet2 VAR cLojCli When .F. SIZE 025,010 OF oDlg1 PIXEL 

@ 033, 005 Say oSay1 PROMPT STR0060 SIZE 100, 010 OF oDlg1 PIXEL COLOR CLR_HBLUE //"Nome"
@ 033, 035 MSGET oGet3 VAR cNomCli SIZE 150,010 OF oDlg1 PIXEL 

@ 048, 005 Say oSay1 PROMPT STR0061 SIZE 100, 010 OF oDlg1 PIXEL COLOR CLR_HBLUE //"Vencimento"
@ 048, 035 MSGET oGet4 VAR dVencto PICTURE "@D" SIZE 040,010 OF oDlg1 PIXEL 

ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT (Eval({ || EnchoiceBar(oDlg1,{|| (nOpca := 1,oDlg1:End()) }, {|| (nOpca:=2,oDlg1:End())},.F.,{}) }))	

If nOpca == 1       
	aValOpe[oBrwOpe:nAt,08] := cCodCli
 	aValOpe[oBrwOpe:nAt,09] := cLojCli
 	aValOpe[oBrwOpe:nAt,10] := dVencto
 	
 	oBrwOpe:SetArray(aValOpe)
 	oBrwOpe:Refresh()
Endif

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A628Val
Validacao da funcao para toca de cliente

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function A628Val(cCodCli,cLojCli,cNomCli,oDlg1)
LOCAL lRet := .T.

SA1->(dbSetorder(01))
If !SA1->( dbSeek(xFilial("SA1")+cCodCli) )
	lRet := .F.
Else
	cLojCli := SA1->A1_LOJA
	cNomCli := SA1->A1_NOME
Endif

lRefresh := .T.
oDlg1:Refresh()

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A628Val
Retorna o Saldo de Debitos e Creditos p faturamento

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function PLSDCINT(cMatricFam,cAno,cMes,aUsuarios,cCodLan,lOnlyLook,cNivel,cChave)
LOCAL aValores := {}
LOCAL cMvPLCDTIT := GetMv("MV_PLCDTIT")
                                     
DEFAULT lOnlyLook 	:= .F.
DEFAULT cNivel  	:= ''
DEFAULT cChave		:= ''
DEFAULT aUsuarios   := {}

While ! PLSSLDDCF->(Eof())
	
	nPos := Iif(Len(aUsuarios)>0, Ascan(aUsuarios,{|x| x[13] == PLSSLDDCF->BSQ_USUARI}), 1)
	
	If Len(aUsuarios)>0 
		If !Empty(PLSSLDDCF->BSQ_USUARI)
			nPos 	:= Ascan(aUsuarios,{|x| x[13] == PLSSLDDCF->BSQ_USUARI})
			cMat	:= aUsuarios[nPos,13]
			cNomUsr := aUsuarios[nPos,3]
		Else
			nPos := Ascan(aUsuarios, {|x| x[7] == cMvPLCDTIT})			
			cMat	:= aUsuarios[nPos,13]
			cNomUsr := aUsuarios[nPos,3]
		Endif
	Else			
		nPos	:= 1
		cMat	:= cChave
		cNomUsr := 'NIVEL DE COBRANCA'
	Endif
	
	If nPos > 0
		aadd(aValores,{cMat  ,;
		cNomUsr				 ,;
		PLSSLDDCF->BSQ_CODLAN,;
		PLSSLDDCF->BSP_DESCRI,;
		PLSSLDDCF->BSP_TIPSER,;
		PLSSLDDCF->BSQ_VALOR ,;
		PLSSLDDCF->BSQ_CODSEQ})
	Endif
	
	PLSSLDDCF->(DbSkip())
Enddo  

PLSSLDDCF->(DbCloseArea())

Return(aValores)



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL268OK
Valida o dialogo de operadoras na odeixando sair sem que pelo menos uma esteja selecionada.

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Static Function PL268OK(aValOpe)
LOCAL lRet := .F.
LOCAL nCnt := 0

If Len(aValOpe) == 0

	Return(lRet)
Endif

For nCnt := 1 To Len(aValOpe)
	If aValOpe[nCnt][6]
		lRet := aValOpe[nCnt][6]
		Exit
	Endif
Next
            
If !lRet
	MsgAlert(STR0062) //"Nenhuma operadora selecionada. Selecione pelo menos uma operadora para continuar."
Endif

Return(lRet)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional 

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Static Function MenuDef()
Private aRotina := {	{ STR0063		, 'AxPesqui' 							, 0 , K_Pesquisar	, 0, .F.},;  //"Pesquisar"
						{ STR0064      , 'PL628MOV("BTF", BTF->(Recno()), 2)'	, 0 , K_Visualizar	, 0, Nil},;  //"Visualizar"
						{ STR0065       , 'PL628MOV("BTF", BTF->(Recno()), 3)'	, 0 , K_Incluir		, 0, Nil},; //"Novo Lote"
						{ STR0066   , 'PL628MOV("BTF", BTF->(Recno()), 4)'	, 0 , K_Imprimir	, 0, Nil},; //"Imprimir Lote"
						{ STR0067   , 'PL628MOV("BTF", BTF->(Recno()), 5)'	, 0 , K_Excluir		, 0, Nil},;
						{ "XML TISS", "PL_M52EXEC('HS_PEDIExp')" /*"HSPAHM52()" "Hs_M52EXEC('HS_PEDIExp')"*/, 0, 2}}    //"Excluir  Lote"
Return(aRotina)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A628MrkVld
Valida o dialogo de operadoras na odeixando sair sem que pelo menos uma esteja selecionada.

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Static Function A628MrkVld( aValOpe, oBrwOpe )

If Empty(aValOpe[oBrwOpe:nAt,08])
	MsgAlert(STR0068)	 //"Não existe cliente para esta operadora! Impossível marcar para ser faturada!"
	aValOpe[oBrwOpe:nAt,6] := .F.
	
Elseif Empty(aValOpe[oBrwOpe:nAt,10])
	MsgAlert(STR0069) //"Nao existe vencimento para esta operadora! Impossóvel marcar para ser faturada!"
	aValOpe[oBrwOpe:nAt,6] := .F.
	    
Elseif M->BTF_TIPCOB == '4' .AND.(aValOpe[oBrwOpe:nAt,25] - aValOpe[oBrwOpe:nAt,26]) <= 0 // Apenas para fatura avulsa...
	MsgAlert(STR0070) //"Valor total apurado é igual a zero! Impossível marcar para ser faturado!"
	aValOpe[oBrwOpe:nAt,6] := .F.

Else
	aValOpe[oBrwOpe:nAt,6] := IF(aValOpe[oBrwOpe:nAt,6],.F.,.T.)
	
Endif

Return()      

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VerTipCob
Verifica e bloqueia tipo de faturamento

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Static Function VerTipCob
Local lRet := .T.
If M->BTF_TPCOB == "1" 
	MsgInfo("Tipo de cobrança 1=NDC não permitida para PTU 5.0a em diante.") 
	lRet := .F.
EndIf          

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A628Aneste
Grava itens do bordero de cobranca de intercambio eventual

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function A628Aneste(cNumCob,cAno,cMes,cOperadora,cOpePEA)
LOCAL cSql 		:= ''
LOCAL cOpe 		:= ''
LOCAL cChave	:= ''
LOCAL cCodCli 	:= ''
LOCAL cCodLoj 	:= ''  
LOCAL cNaturez	:= ''
LOCAL lret		:= .F.
LOCAL aValOpe   := {}
LOCAL bOk		:= {|| Iif(PL268OK(aValOpe), (lRet:=.T., oDlg:End()), NIL)}
LOCAL bCancel	:= {|| Iif(MsgYesNo(STR0031),(lRet:=.F., oDlg:End()),NIL)} //"Deseja Abandorar o Lote?"
LOCAL nValor	:= 0
LOCAL dVenc		:= cTod('')
LOCAL oGrupo1
LOCAL oGrupo2
LOCAL oSay		       
LOCAL nPos       := 0
LOCAL nQtdEv     := 0
LOCAL nDiasSrvPrt := GetNewPar("MV_PLDIAPZ",150)

//Monta query principal com os registro de intercambio Anestesista...  

cSql := "SELECT BD6_CODOPE, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_OPEEXE, BD6_VLRPAG, BD6_VLRBPR, BD5.R_E_C_N_O_ "
cSql += "FROM "+RetSqlName("BD6")+" BD6 "
cSql += " INNER JOIN "+RetSqlName("BD5")+" BD5 " 
cSql += " ON  BD5.BD5_FILIAL = BD6.BD6_FILIAL " 
cSql += " AND BD5.BD5_CODOPE = BD6.BD6_CODOPE " 
cSql += " AND BD5.BD5_CODLDP = BD6.BD6_CODLDP " 
cSql += " AND BD5.BD5_CODPEG = BD6.BD6_CODPEG " 
cSql += " AND BD5.BD5_NUMERO = BD6.BD6_NUMERO "   
cSql += " AND BD5.BD5_CODLDP = '"+GetNewPar("MV_PLSPREM","9000")+"' " 
cSql += " AND BD5.BD5_REEANE = '1' "
cSql += " AND BD5.BD5_ENV507 = '0' "

//Trata cobranca retroativa inferior a data estabelecida no manual     
cData := (M->BTF_DATGER-nDiasSrvPrt)
If M->BTF_RETROA <> '1'   
	cData := (M->BTF_DATGER-nDiasSrvPrt)
	cSql += "AND BD5_DATPRO >= '"+Dtos(cData)+"' "
Endif    

cSql += "AND BD5.D_E_L_E_T_ <> '*' "
cSql += " WHERE BD6_FILIAL = '"+xFilial("BD6")+"' "
cSql += " AND BD6_CODOPE = '"+cOperadora+"' "
cSql += " AND BD6_ANOPAG =  '"+cAno+"' " 
cSql += " AND BD6_MESPAG =  '"+cMes+"' "
cSql += " AND (BD6_CONCOB = '1' OR BD6_CONCOB = ' ' ) " 
cSql += " AND BD6_VLRPAG > BD6_VLRBPR "
cSql += " AND BD6_FASE IN ('3','4') " 
cSql += " AND BD6_SITUAC  = '1' "
cSql += " AND BD6_BLOCPA <> '1' " 
cSql += " AND BD6.D_E_L_E_T_ <> '*' " 
cSql += " GROUP BY BD6_CODOPE, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_OPEEXE, BD6_VLRPAG, BD6_VLRBPR, BD5.R_E_C_N_O_ "
cSql += " ORDER BY BD6_OPEEXE"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TRB1", .F., .T.)
                                                     
TRB1->( dbGotop() )
While !TRB1->( Eof() )
	
	nPos:= 0
	
	//Variaveis agrupadoras... controle do loop...                         
	
	cOpe := TRB1->BD6_OPEEXE
	
	//Posiciona a operadora...                                             
	
	BAO->( dbSetorder(01) )
	BA0->( dbSeek(xFilial("BA0")+cOpe) )
	
	//cliente sera o da operadora  											 |
	
	cCodCli := BA0->BA0_CODCLI
	cCodLoj := BA0->BA0_LOJCLI
	
	//Obtem a natureza para geracao do titulo...                           
	
	cNaturez := BA0->BA0_NATURE
		                       
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCodCli+cCodLoj))
	
	
	//Verifica se contrato (BT5) e de custo operacional...                 
	
	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+Trb1->(BD6_CODOPE+BD6_CODEMP+BD6_MATRIC)))
	BT5->(DbSetOrder(1))
	If BT5->(DbSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON)))
		If BT5->BT5_MODPAG <> "2" //Se nao for for de custo operacional devera ser faturada como
			Trb1->(DbSkip())
			Loop
		Endif
	Endif
	
	//Posiciona o usuario...                                               
	
	BA1->( dbSetorder(2) )
	BA1->( dbSeek(xFilial("BA1")+TRB1->(BD6_CODOPE+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)) )
	
	//Chave usada para pesquisar titulo no na gracao do mesmo...           
	
	cChave := TRB1->(BD6_CODOPE+BD6_CODEMP+BD6_MATRIC)

	
	//Inicia o processamento...                 
	
	While ! TRB1->( Eof() ) .and. TRB1->BD6_OPEEXE == cOpe 
		
		
		//Verifica se foi informado vencimento generico no cab. do lote.		
		dVenc := cTod('')		
		If !Empty(M->BTF_VENCTO)
			dVenc := M->BTF_VENCTO
		Endif		
		
		nValor := TRB1->BD6_VLRPAG - TRB1->BD6_VLRBPR		
		
		//Calcula a data de vencimento da fatura...                 
		
		If Empty(dVenc)
			If BA0->BA0_VENCUS > 0
				dVenc := PL628Venc(BA0->BA0_VENCUS,cMes,cAno,BA0->BA0_TIPCUS)
			Else
				dVenc := cTod('')
			Endif
		Endif
					
		If nPos == 0
			nQtdEv ++
			Aadd( aValOpe, {cOpe,;					// Operadora origem
			BA0->BA0_NOMINT,;							// Nome da operadora origem
			Round(nValor,2),;							// Custo Operacional Servicos Medicos
			0,;											// Valor da taxa administrativa
			{TRB1->R_E_C_N_O_},;						// Recno do arquivo 
			Iif((!Empty(BA0->BA0_CODCLI)  .AND.;
			!Empty(BA0->BA0_VENCTO)),.T.,.F.),;   		// flag que permite selecao no browse
			nQtdEv,;									// Intercambio
			cCodCli,;									// Codigo do cliente
			cCodLoj,;									// Loja do cliente
			dVenc,;										// Vencimento
			{},;										//
			0,;											// Custo Operacional Servicos Acessorios
			'',;										// Empresa origem, para controle de clientes especificos
			cNaturez,;                                 	// Natureza
			0,;		// Custo Operacional Outros Servicos
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;											// Outros Debitos
			0,;											// Outros Creditos
			BA0->BA0_TIPPAG,;	// Tipo de pagamento
			BA0->BA0_PORTAD,;	// Portador
			BA0->BA0_AGEDEP,;	// Agencia do portador
			BA0->BA0_CTACOR,;	// Conta do portador
			BA0->BA0_BCOCLI,;	// Banco do cliente
			BA0->BA0_AGECLI,;	// Agencia do cliente
			BA0->BA0_CTACLI,;	// Conta do cliente
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0,;
			0})
			nPos := Len(aValOpe)
		Else
			aValOpe[nPos][3] += nValor
			Aadd(aValOpe[nPos][5],TRB1->R_E_C_N_O_)
		Endif
		
		TRB1->( dbSkip() )
	Enddo
Enddo

If Len(aValOpe) == 0
	Help("",1,"REGNOIS")
	BA3->(DbClearFilter())
	BA3->(RetIndex("BA3"))       
    
	TRB1->( dbClosearea() )
	Return({.F.,{}})
Endif


//Ordena o array por  ordem de operadora!                              

Asort(aValOpe,,,{|x, y| x[1] < y[1]})


//Tecla de atalho para trocar o cliente...                             

SetKey(VK_F10,{||A628Clie(@aValOpe, oBrwOpe)}) 


//Monta tela pra selecao das operadoras a serem faturadas...           

DEFINE MSDIALOG oDlg TITLE STR0032+M->BTF_ANOINI+" / "+M->BTF_MESINI FROM ndLinIni,ndColIni TO ndLinFin+5,ndColFin OF GetWndDefault() //"Competencia "

@ 035, 005 GROUP oGrupo1 TO 032,150 OF oDlg  COLOR CLR_HBLUE PIXEL
@ 040, 010 Say oSay PROMPT STR0033 SIZE 200, 006 OF oGrupo1 PIXEL COLOR CLR_HBLUE //"MARQUE AS OPERADORAS A SEREM FATURADAS"

@ 035, 220 GROUP oGrupo2 TO 032,350 OF oDlg  COLOR CLR_HBLUE PIXEL
@ 040, 225 Say oSay PROMPT STR0034 SIZE 200, 006 OF oGrupo2 PIXEL COLOR CLR_HBLUE //"F10 - PARA MUDAR O CLIENTE E O VENCIMENTO"

oBrwOpe := TcBrowse():New( 055, 000, 356, 165,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )             
oBrwOpe:lHScroll 	:= .t.
oBrwOpe:lVScroll 	:= .t.
oBrwOpe:AddColumn(TcColumn():New(" ",{ || IF(aValOpe[oBrwOpe:nAt,6],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
         "@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))     
                  
oBrwOpe:AddColumn(TcColumn():New(STR0035,{ || OemToAnsi(aValOpe[oBrwOpe:nAt,1]) },; //"Operadora"
         "@!",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))     

oBrwOpe:AddColumn(TcColumn():New(STR0036,{ || OemToAnsi(aValOpe[oBrwOpe:nAt,2]) },; //"Descricao"
         "@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))     
         
oBrwOpe:AddColumn(TcColumn():New(STR0037,{ || OemToAnsi(Transform(aValOpe[oBrwOpe:nAt,7],"@E 99999")) },; //"Eventos"
         "@!",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))                                                    

oBrwOpe:AddColumn(TcColumn():New("Valor Diferença Reembolso",{ || OemToAnsi(Transform(	aValOpe[oBrwOpe:nAt,03],"@E 999,999,999.99")) },;
																	         nil,nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil))     

oBrwOpe:AddColumn(TcColumn():New(STR0045,{ || aValOpe[oBrwOpe:nAt,10]},; //"Vencto."
         nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))              
         
oBrwOpe:AddColumn(TcColumn():New(STR0046,{ || aValOpe[oBrwOpe:nAt,08]},; //"Cliente"
         nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))                       
         
oBrwOpe:AddColumn(TcColumn():New(STR0047,{ || aValOpe[oBrwOpe:nAt,09]},; //"Loja"
         nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))                                

oBrwOpe:AddColumn(TcColumn():New(STR0046,{ || Posicione("SA1",1,xFilial("SA1")+aValOpe[oBrwOpe:nAt,08]+; //"Cliente"
											    aValOpe[oBrwOpe:nAt,09],"A1_NOME")},;
										        nil,nil,nil,nil,700,.F.,.F.,nil,nil,nil,.F.,nil))                       										                          
oBrwOpe:SetArray(aValOpe)         
oBrwOpe:bLDblClick := { || A628MrkVld( aValOpe, oBrwOpe ) }

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})
			

//Desfaz filtro...                                                     

BA3->(DbClearFilter())
BA3->(RetIndex("BA3"))       


//Reseta tecla de atalho...                                            

SET KEY VK_F10 TO

TRB1->( dbClosearea() )
Return({lRet,aValOpe,cChave})

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A628GrvAne
Grava itens do bordero de cobranca de intercambio eventual

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Static Function A628GrvAne(aRet,nCnt,nSeq,aNumTit,cTipCob)
LOCAL y             := 0
LOCAL nVALOR  		:= 0
LOCAL nValTit  		:= 0
LOCAL nQtdTit  		:= 1
LOCAL nOPEGER       := 0
LOCAL bEmissao 		:= {|| Iif( !Empty(M->BTF_DTEMIS), M->BTF_DTEMIS, dDataBase ) }
LOCAL cMatFam  		:= ''
LOCAL cPrefix  		:= ""
LOCAL cNumTit  		:= ""
local cOrigem 		:= "PLSA628"  
LOCAL cTipTit  		:= ""
LOCAL aEventosCb 	:= PLSINPBFQ(PlsIntPad()) 
LOCAL aBases		:= {0,0,0,0,0,0}
LOCAL aVlrCob  		:= {}
LOCAL aCpoSE1       := {}
LOCAL nDias    		:= getNewPar("MV_PLSDVEN", 0)
LOCAL lNCC         	:= .F.
local lErro 		:= .f.

DEFAULT cTipCob 	:= '2' //Padrao de geracao e o modelo antigo 2-Fatura

aNumTit  := PLSA625MDa(M->BTF_ANOINI,M->BTF_MESINI,"1","2",nil,"6")
cPrefix  := aNumTit[1]
cNumTit  := aNumTit[2]
cTipTit  := aNumTit[3]

If Empty(cTipTit)
	cTipTit:= getNewPar("MV_PLSTIP", "DP ")
Endif

nValTit  := aRet[2][nCnt][3]

nQtdTit  := 1 
nOPEGER  := 1


//Posiciona a primeira familia... so para constar!!        		

cMatFam := aRet[3] 
BA3->( dbSetorder(01) )
BA3->( dbSeek(xFilial("BA3")+cMatFam) )
 

//Posiciona Subcontrato...                                        

nDecresc := 0
BQC->(DbSetOrder(1))
If BQC->( MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)) ) .And. BQC->BQC_PERCON > 0
	nDecresc := (nValTit * BQC->BQC_PERCON) / 100
Endif            

dVencto := aRet[2][nCnt][10]	

// Geração Título
IncProc(STR0058+cNumTit+"  /  " + STR0035 + ": "+aRet[2][nCnt][1]) //"Titulo Numero:" //"Operadora"
ProcessMessage()

Aadd(aCpoSE1, {'E1_PREFIXO', cPrefix, nil } )
Aadd(aCpoSE1, {'E1_SERIE', cPrefix, nil } )
Aadd(aCpoSE1, {'E1_NUM', cNumTit, nil } )
Aadd(aCpoSE1, {'E1_PARCELA', '', nil } )
Aadd(aCpoSE1, {"E1_TIPO", cTipTit, nil } )
Aadd(aCpoSE1, {"E1_CLIENTE", aRet[2][nCnt][8], nil	} )
Aadd(aCpoSE1, {"E1_LOJA", aRet[2][nCnt][9], nil	} )
Aadd(aCpoSE1, {"E1_NATUREZ", aRet[2][nCnt][14], nil } )
Aadd(aCpoSE1, {'E1_NUMBCO', aNumTit[3], nil } )
Aadd(aCpoSE1, {'E1_PLNUCOB', Subs(aRet[3],1,4)+BTF->BTF_NUMERO, nil } )
Aadd(aCpoSE1, {'E1_ORIGEM', cOrigem, nil } )
Aadd(aCpoSE1, {'E1_LA', "", nil } )

//calcula novamente o vencimento									
If dVencto < dDataBase 
	dVencto := dDataBase + nDias
EndIf 

Aadd(aCpoSE1, {'E1_VENCTO', dVencto, nil } )
Aadd(aCpoSE1, {'E1_VENCREA', DataValida(dVencto), nil } )
Aadd(aCpoSE1, {"E1_EMISSAO", Eval(bEmissao), nil } )
Aadd(aCpoSE1, {'E1_VALOR', nValTit, nil } )
Aadd(aCpoSE1, {'E1_SALDO', nValTit, nil } )

Aadd(aCpoSE1, {'E1_CODINT', BA3->BA3_CODINT, nil } )
Aadd(aCpoSE1, {'E1_CODEMP', BA3->BA3_CODEMP, nil } )
Aadd(aCpoSE1, {'E1_MATRIC', BA3->BA3_MATRIC, nil} )
Aadd(aCpoSE1, {'E1_CODCOR', BA3->BA3_CODVEN, nil	} )

cAno := BTF->BTF_ANOINI
cMes := BTF->BTF_MESINI

Aadd(aCpoSE1, {'E1_ANOBASE', cAno, nil	} )
Aadd(aCpoSE1, {'E1_MESBASE', cMes, nil	} )
Aadd(aCpoSE1, {'E1_PLORIG', "2" , nil } )
Aadd(aCpoSE1, {'E1_SDACRES', 0, nil } )
Aadd(aCpoSE1, {'E1_FORMREC', aRet[2][nCnt][27], nil } )
Aadd(aCpoSE1, {'E1_MULTNAT', "2", nil } )
Aadd(aCpoSE1, {"E1_PORTADO", aRet[2][nCnt][28], nil } )
Aadd(aCpoSE1, {"E1_AGEDEP", aRet[2][nCnt][29], nil } )
Aadd(aCpoSE1, {"E1_CONTA", aRet[2][nCnt][30], nil } )
Aadd(aCpoSE1, {'E1_BCOCLI', aRet[2][nCnt][31], nil } )
Aadd(aCpoSE1, {'E1_AGECLI', aRet[2][nCnt][32], nil } )
Aadd(aCpoSE1, {'E1_CTACLI', aRet[2][nCnt][33], nil } )

// Incia a geracao do titulo e baixa do saldo
Begin Transaction

cAnoRef := cAno
cMesRef := strzero(val(cMes) - 1, 2)

If Val(cMesRef) <= 0
	cMesRef := "12"
	cAnoRef := strzero(val(cAno) - 1, 4)
EndIf

//Gravacao do E1																		
//Gera nota/titulo																	
lErro := PLSTOSE1(aCpoSE1,aBases,cMesRef,cAnoRef,cOrigem,.f.,.F.,aVlrCob,cPrefix,cNumTit,0,0,lNCC,aEventosCb)

if ! lErro

	If ! SE1->( Eof() )
		SE1->( RecLock("SE1", .F.) )
			SE1->E1_SITUACA := "0"
		SE1->(MsUnLock())
	EndIf

	// Titulo de valor irrisório. Providenia a baixa por cancelamento.
	If nValTit <= 0.03   

		PL627BXCAN(.t.)

		lBaixaCan := .t.

	Endif

	nVALOR := aRet[2][nCnt][03]

	BTO->( RecLock("BTO",.T.) )

	BTO->BTO_FILIAL := 	xFilial("BTO")
	BTO->BTO_CODOPE := BTF->BTF_CODOPE
	BTO->BTO_OPEORI := aRet[2][nCnt][1]
	BTO->BTO_NUMERO := BTF->BTF_NUMERO
	BTO->BTO_DATGER := BTF->BTF_DATGER
	BTO->BTO_USUOPE := BTF->BTF_USUOPE
	BTO->BTO_HORA   := BTF->BTF_HORA
	BTO->BTO_ANOINI := BTF->BTF_ANOINI
	BTO->BTO_MESINI := BTF->BTF_MESINI
	BTO->BTO_CODINT := BTF->BTF_CODOPE
	BTO->BTO_QTDEVE := aRet[2][nCnt][07]
	BTO->BTO_VLRCP3 := nVALOR		
	BTO->BTO_CUSTOT := nVALOR
	BTO->BTO_SEQUEN := StrZero(nSeq,3)
	BTO->BTO_STATUS := '1'

	//Grava informacoes financeiras...				                     

	BTO->BTO_PREFIX := SE1->E1_PREFIXO
	BTO->BTO_NUMTIT := SE1->E1_NUM
	BTO->BTO_PARCEL := SE1->E1_PARCELA
	BTO->BTO_TIPTIT := SE1->E1_TIPO

	If cTipCob == '3'
		BTO->BTO_TPMOV := '3'
		If i == 1  //NDC
			BTO->BTO_TPCOB := '1' //3
		ElseIf i == 2 //Fatura
			BTO->BTO_TPCOB := '2'
		EndIf
	ElseIf cTipCob == '2'
		BTO->BTO_TPMOV := '2'
		BTO->BTO_TPCOB := '2'
		
	ElseIf cTipCob == '1'
		BTO->BTO_TPMOV := '1'
		BTO->BTO_TPCOB := '1'
	EndIf

	//Atualiza a tabela de movimentacoes, marcando os registros ja Importados...³

	For y := 1 To Len(aRet[2][nCnt][5])
		BD5->( dbGoto(aRet[2][nCnt][5][y]) )
		If !BD5->( Eof() )
			BD5->( RecLock("BD5",.F.) )
			BD5->BD5_ENV507 := '1'
			BD5->BD5_PRE507 := BTO->BTO_PREFIX
			BD5->BD5_NUM507 := BTO->BTO_NUMTIT
			BD5->BD5_PAR507 := BTO->BTO_PARCEL
			BD5->BD5_TIP507 := BTO->BTO_TIPTIT
			BD5->( msUnlock() )
		Endif
	Next
	
	BTO->BTO_REEANE := "1"
	BTO->( msUnlock() )

	//Atualiza o cabecalho do lote...                                      

	BTF->( RecLock("BTF",.F.) )	
		BTF->BTF_VLRCP3 := nVALOR	                     
		BTF->BTF_CUSTOT := nVALOR
		BTF->BTF_OPEGER := nOPEGER
		BTF->BTF_DTEMIS := Eval(bEmissao) 
	BTF->( msUnlock() )

endIf

End Transaction
	
Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSASE1ANE
Grava itens do bordero de cobranca de intercambio eventual

@author    Geraldo Felix Junior
@version   V8
@since     29.03.04
/*/
Function PLSASE1ANE(cNumCob)
local cFor 	:= "" 
local cArea := Alias()
local lRet  := .t.

//Selectiona os titulos pertencentes ao lote...                            
cFor := "SELECT R_E_C_N_O_ E1_RECNO FROM " + RetSqlName("SE1")
cFor += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND E1_PLNUCOB = '"+cNumCob+"' AND "
cFor += "D_E_L_E_T_ = ' '"

cFor := ChangeQuery(cFor)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFor), "SE1QRY", .F., .T.)

//Analiza baixas e a situacao do titulo, antes de exclui-lo...        
SE1QRY->( dbGotop() )
while ! SE1QRY->(Eof())

	if SE1QRY->( dbGoto(E1_RECNO) )
		
		//exclui titulos ou nota				
		if ! P629ExcE1()
			disarmTransaction()
			lRet := .f.
			exit
		endIf

	endIf

SE1QRY->( dbSkip() )
endDo	

SE1QRY->( dbClosearea() )
                                  
if ! Empty(cArea)
	DbSelectArea(cArea)
endIf

return(lRet)             
