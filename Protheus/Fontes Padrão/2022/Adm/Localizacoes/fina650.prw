#INCLUDE "fina650.ch"
#include "protheus.ch"
#include "tcbrowse.ch"

Static aPrazos
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA650  บAutor   ณBruno Sobieski      บFecha ณ  18-05-08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para geracao de provisao para cobranca duvidosas     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fina650()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis 											 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0001) //"Geracao de provisao para cobranca duvidosa"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restringe o uso do programa ao Financeiro e Sigaloja	    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !(AmIIn(6,12,17,72))		// Sข Fin e Loja e EIC e SIGAPHOTO
	Return
Endif
//Carrega percentuais
Fa650SetPrz(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Enderea a Funo de BROWSE											  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"SE1",,,,,, Fa650Leg("SE1"))

dbSelectArea("SE1")
dbSetOrder(1)

aPrazos	:=	Nil
Return
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Fa650Gera ณ Autor ณ Bruno Sobieski      ณ Data ณ 18.05.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Gera a provisao .                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fa650Gera                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Fa650Gera()
Local bNewProc	:=	{|oCenterPanel,lEnd| AuxGera(oCenterPanel)}
LOCAL aTreeProc := {}   
Local nX
Local cTxtProc	:= STR0002+CRLF		 //"O Objetivo desta rotina ้ gerar lancamentos contแbeis das provisoes para cobranca duvidosa"
cTxtProc	+= STR0003	+CRLF //"O valor das provisoes sera calculado com base nos parametros escolhidos para o reprocesamento e "
cTxtProc	+= STR0004	+CRLF+CRLF //"nos limites e percentuais informados:"
For nX:= 1 To Len(aPrazos) 
	If nX == 1
		cTxtProc	+=	STR0005+Str(aPrazos[nX,2],5)+STR0006+Str(aPrazos[nX,3],6,2)+"%"+CRLF+CRLF //"Vencidos a  mais de "###" dias : "
	Else
		cTxtProc	+=	STR0007+Str(aPrazos[nX,2],5)+STR0008+Str(aPrazos[nX-1,2],5)+STR0009+Str(aPrazos[nX,3],6,2)+"%"+CRLF //"Vencidos entre "###" e "###" dias: "
	Endif
Next

//aAdd(aTreeProc,{OemToAnsi("Log"),{|oCenterPanel| PreLogView(oCenterPanel)},"BPMSDOCI"})
Pergunte("FINA650001",.F.)

tNewProcess():New("FINA650",OemToAnsi(STR0001),bNewProc,cTxtProc,"FINA650001",aTreeProc)	 //"Geracao de provisao para cobranca duvidosa"

Return                                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  AuxGera  บAutor   ณBruno Sobieski      บFecha ณ  18-05-08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para geracao de provisao para cobranca duvidosas     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AuxGera(oSelf)
Local cAliasQry1	:=	GetNextAlias()
Local nPerc	:=	0
Local nValProv:=	0
Local aProvisao		:=	{}
Local cArquivo		:=	""
Local nTotalLanc	:=	0 
Local nX
Local aDiario		:=	{}
Local lOnline		:=	.F.
Local aFlagCTB := {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local cWherVen	:= "%%" // Define qual o vencimento do E1 serแ escolhido pelo usuแrio no PE para execu็ใo da Query.
Local cCpoVenc	:= "E1_VENCREA" // Vencimento padrใo utilizado pelo sistema.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ VerIfica o numero do Lote 									 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE cLote
LoteCont( "FIN" )

Pergunte("FINA650001",.F.)

If Len(aPrazos) > 0
	oSelf:Savelog(STR0010) //"Processamento iniciado."
	oSelf:SetRegua1(3)
	oSelf:IncRegua1()
	oSelf:SetRegua2(2)
	oSelf:IncRegua2()
	nTam:=	  TAMSX3("E1_SALDO")[1]
	nDec:=	  TAMSX3("E1_SALDO")[2]
	cNotIn		:= '%'+FormatIn(MVRECANT+"|"+MV_CPNEG,"|")+"%"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ponto de entrada permite a escolha do campo relativo ao vencimento que serแ observado ao ณ
	//ณ gerar a provisใo                                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	    
	If ExistBlock("F650VnPro")
		cCpoVenc := ExecBlock("F650VnPro",.F.,.F.)
		// Verifica se existe o campo na tabela SE1
		If SE1->( FieldPos(cCpoVenc) ) <= 0
			cCpoVenc := "E1_VENCREA" // Vencimento padrใo utilizado pelo sistema.
			Help(" ",1,"NOMECPO")
		EndIf
	Endif
	cWherVen := "% " +cCpoVenc+ " < '" +dTOS(aPrazos[Len(aPrazos),1]) + "' %"
	cCpoVenc := "%" +cCpoVenc+ "%"
		BeginSql Alias cAliasQry1
	
		COLUMN E1_EMIS1 AS DATE
		COLUMN E1_VENCREA AS DATE
		COLUMN E1_VENCTO AS DATE
		COLUMN E1_SALDO AS NUMERIC(nTam,nDec)               	                                                          
		COLUMN E1_MOEDA AS NUMERIC(2,0)               	                                                          
	
		SELECT E1_SALDO,E1_MOEDA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, %exp:cCpoVenc%, E1_EMIS1, SUM(FIA_VALOR) FIA_VALOR
		FROM %table:SE1% SE1 
			LEFT JOIN %TABLE:FIA% FIA ON FIA_FILIAL = %xFilial:FIA%
			  				AND FIA_CLIENT	=	E1_CLIENTE
			  				AND FIA_LOJA	=   E1_LOJA
			  				AND FIA_PREFIX	=   E1_PREFIXO
			  				AND FIA_NUM		=   E1_NUM
			  				AND FIA_PARCEL	=   E1_PARCELA
			  				AND FIA_TIPO	=   E1_TIPO
			WHERE E1_FILIAL = %xFilial:SE1%
		          AND  E1_CLIENTE BETWEEN %exp:mv_par01% AND  %exp:mv_par02% 
		          AND  E1_PREFIXO BETWEEN %exp:mv_par03% AND  %exp:mv_par04% 
		          AND  E1_TIPO    BETWEEN %exp:mv_par05% AND  %exp:mv_par06% 
		          AND  E1_NATUREZ BETWEEN %exp:mv_par07% AND  %exp:mv_par08% 
		          AND  %exp:cWherVen% 
		  	      AND  E1_TIPO NOT IN %exp:cNotIn%
		  		  AND  SE1.%NotDel%
			GROUP BY E1_SALDO,E1_MOEDA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, %exp:cCpoVenc%, E1_EMIS1
			ORDER BY %exp:cCpoVenc%
		EndSql
	
	oSelf:Savelog(STR0011) //"Fim selecao movimentos."
	cCpoVenc := SUBSTR(cCpoVenc,2,LEN(cCpoVenc)-2) // Retiro as tags
	While !EOF()     
		nPerc	:=	GetPerc(&cCpoVenc)
		nValProv	:=	(nPerc*E1_SALDO/100)-FIA_VALOR
		If Abs(nValProv) > 0 .And. Abs(nValProv) >= mv_par09
			AADD(aProvisao, {E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_MOEDA, nValProv})
		Endif
		dBsKIP()
	Enddo                                      
	
	oSelf:IncRegua2()
	oSelf:Savelog(STR0012+Str(Len(aProvisao))+STR0013) //"Calculadas "###" Provisoes. Gravando movimentos..."
	oSelf:IncRegua1()
	DbCloseArea()
	oSelf:SetRegua2(Len(aProvisao) +1 )
Endif
If Len(aProvisao) > 0
	Begin Transaction
	lOnline	:= (mv_par12 == 1 .And. VerPadrao('51A'))
	If lOnline
		nHdlPrv:=HeadProva(cLote,"FINA650",Substr(cUsuario,7,6),@cArquivo)
	Endif
	For nX := 1 To Len(aProvisao)  
		oSelf:IncRegua2()
		cNextSeq	:=	GetSeq(aProvisao[nX])
		RecLock('FIA',.T.)
		FIA_FILIAL	:=  xFilial('FIA')
		FIA_PREFIX	:=  aProvisao[nX,1]
		FIA_NUM		:=  aProvisao[nX,2]
		FIA_PARCEL	:=  aProvisao[nX,3]
		FIA_TIPO	:=  aProvisao[nX,4]
		FIA_CLIENT	:=	aProvisao[nX,5]
		FIA_LOJA	:=  aProvisao[nX,6]
		FIA_MOEDA	:=  aProvisao[nX,7]
		
		FIA_VALOR	:=  aProvisao[nX,8]
		FIA_VLLOC	:=  xMoeda(aProvisao[nX,8],aProvisao[nX,7],1,dDataBase)
		FIA_SEQ		:=	cNextSeq
		FIA_DIACTB	:=	MV_PAR10
		FIA_DTPROV	:=	dDataBase
		MsUnLock()
		If lOnline

			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
				aAdd( aFlagCTB, {"FIA_LA", "S", "FIA", FIA->( Recno() ), 0, 0, 0} )
			Endif
			nTotalLanc += DetProva( nHdlPrv, '51A', "FINA650", cLote, /*nLinha*/, /*lExecuta*/,;
			                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
			                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
         If UsaSeqCor()
				aadd(aDiario,{"FIA",FIA->(RECNO()),FIA->FIA_DIACTB,"FIA_NODIA","FIA_DIACTB"})
			Else
				aDiario := {}
			EndIf
		Endif
	Next            
	If lOnline
		//+-----------------------------------------------------+
		//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
		//+------------------------`-----------------------------+
		RodaProva(nHdlPrv,nTotalLanc)
		
		//+-----------------------------------------------------+
		//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
		//+-----------------------------------------------------+     

		

		If !cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, (mv_par11 == 1) /*lDigita*/,;
		               (mv_par12 == 1) /*lAglut*/, /*cOnLine*/, /*dData*/, /*dReproc*/,;
		               @aFlagCTB, /*aDadosProva*/, aDiario )
			If cPaisLoc =="PTG"
				Final(STR0014) //"Erro na geracao da contabilizao"
			Endif       
		Endif	
		
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
		
	Endif
	End Transaction
Endif
oSelf:Savelog(STR0015) //"Processamento finalizado."
If !IsBlind()
	If Len(aProvisao) > 0 
		Aviso(STR0016,STR0017,{STR0018}) //"Finalizado"###"Provisoes geradas com sucesso"###"Ok"
	Else
		Aviso(STR0016,STR0019,{STR0018}) //"Finalizado"###"Nenhuma provisao foi gerada"###"Ok"
	Endif
Endif		
Return     

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFa650VPROV  ณ Autor ณ Bruno Sobieski      ณ Data ณ 22.10.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Visualiza as provisoes                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fina650                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function FA650VProv(cAlias,nReg,nOpc)
Local	cSeek
Local bWhile
Local oDlg
Local cQuery
Local lQuery	:= .T.
Private	aHeader	:=	{}
Private aCols		:=	{}
//+--------------------------------------------------------------+
//| Cria variaveis M->????? da Enchoice                          |
//+--------------------------------------------------------------+
RegToMemory("SE1",.F.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Filtros para montagem do aCols                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("FIA")
dbSetOrder(1)
#IFDEF TOP
	lQuery  := .T.
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("FIA")+" FIA "
	cQuery += "WHERE FIA.FIA_FILIAL='"+xFilial("FIA")+"' "
	cQuery += "	  				AND FIA_CLIENT		=	'"+SE1->E1_CLIENTE+"' "
	cQuery += "		  				AND FIA_LOJA		= '"+SE1->E1_LOJA		+"' "
	cQuery += "		  				AND FIA_PREFIX	=	'"+SE1->E1_PREFIXO+"' "
	cQuery += "		  				AND FIA_NUM			= '"+SE1->E1_NUM		+"' "
	cQuery += "		  				AND FIA_PARCEL	= '"+SE1->E1_PARCELA+"' "
	cQuery += "		  				AND FIA_TIPO		=	'"+SE1->E1_TIPO		+"' "
	cQuery += "		  				AND D_E_L_E_T_	=	' ' "
	cQuery += "ORDER BY "+SqlOrder(FIA->(IndexKey()))
	dbSelectArea("SC6")
	dbCloseArea()
#ENDIF
cSeek  := xFilial("FIA")+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
bWhile := {|| xFilial("FIA")+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aHeader e aCols                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,       ณ
//ณ				  cQuery, bMountFile, lInclui )                                                                ณ
//ณnOpcx			- Opcao (inclusao, exclusao, etc).                                                         ณ
//ณcAlias		- Alias da tabela referente aos itens                                                          ณ
//ณnOrder		- Ordem do SINDEX                                                                              ณ
//ณcSeekKey		- Chave de pesquisa                                                                            ณ
//ณbSeekWhile	- Loop na tabela cAlias                                                                        ณ
//ณuSeekFor		- Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar ณ
//ณ				  o registro)                                                                                  ณ
//ณaNoFields	- Array com nome dos campos que serao excluidos na montagem do aHeader                         ณ
//ณaYesFields	- Array com nome dos campos que serao incluidos na montagem do aHeader                         ณ
//ณlOnlyYes		- Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario   ณ
//ณcQuery		- Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera     ณ
//ณ	           parametros cSeekKey e bSeekWhiele)                                                              ณ
//ณbMountFile	- Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)                     ณ
//ณlInclui		- Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco                 ณ
//ณaHeaderAux	-                                                                                              ณ
//ณaColsAux		-                                                                                              ณ
//ณbAfterCols	- Bloco executado apos inclusao de cada linha no aCols                                         ณ
//ณbBeforeCols	- Bloco executado antes da inclusao de cada linha no aCols                                     ณ
//ณbAfterHeader -                                                                                              ณ
//ณcAliasQry	- Alias para a Query                                                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FillGetDados(2,"FIA",1,cSeek,bWhile,,,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,.F.,/*aHeaderAux*/,/*aColsAux*/,,/*bBeforeCols*/,/*bAfterHeader*/,"FIATRB")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz o calculo automatico de dimensoes de objetos     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( cAlias, nReg, nOpc, , , , , aPosObj[1],,3,,,)
	MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,"",,,,,,,,,,,)	
	oDlg:lMaximized := .T.
	ACTIVATE MSDIALOG oDlg On INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
Return
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFa650Leg    ณ Autor ณ Bruno Sobieski      ณ Data ณ 22.10.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma janela contendo a legenda da mBrowse ou retorna a ณฑฑ
ฑฑณ          ณ para o BROWSE                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fina650                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Fa650Leg(cAlias, nReg)
Local aCores := {"BR_PRETO","BR_AZUL","BR_MARRON","BR_CINZA", "BR_LARANJA","BR_PINK","BR_AMARELO" }
Local nX
Local aRet	:=	{}
If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	If Len(aPrazos) > 0
		For nX:= 1 To Len(aPrazos) +1
			If nX == 1
				aadd(aRet,{"SE1->(E1_SALDO > 0 .And. Dtos(E1_VENCREA) <= '"+Dtos(aPrazos[nX,1])+"')",aCores[nX]})
			ElseIf nX <= Len(aCores)  .And. nX <= Len(aprazos) 
				aadd(aRet,{"SE1->(E1_SALDO > 0 .And. Dtos(E1_VENCREA) > '"+Dtos(aPrazos[nX-1,1])+"' .And. Dtos(E1_VENCREA) <= '"+Dtos(aprazos[nX,1])+"')",aCores[nX]})
			ElseiF nX > len(aPrazos)
				aadd(aRet,{"SE1->(E1_SALDO > 0 .And. Dtos(E1_VENCREA) > '"+Dtos(aprazos[nX-1,1])+"' .And. Dtos(E1_VENCREA) <= '"+dtos(ddatabase)+"')",If(nX > len(aCores),'BR_BRANCO',aCores[nX])})
			Endif
		Next
	Endif
	Aadd(aRet,{"SE1->(E1_SALDO > 0 .And. Dtos(E1_VENCREA) > '"+Dtos(dDataBase)+"')",'BR_VERDE'})
	Aadd(aRet,{"SE1->(E1_SALDO == 0 )",'BR_VERMELHO'})
Else
	If Len(aPrazos) > 0
		For nX:= 1 To Len(aprazos) +1
			If nX == 1
				aadd(aRet,{aCores[nX], STR0020+Str(aPrazos[nX,2],5)+STR0021}) //"Venc. mais de "###" dias"
			ElseIf nX <= Len(aCores)  .And. nX <= Len(aprazos) 
				aadd(aRet,{aCores[nX], STR0022+Str(aPrazos[nX,2],5)+STR0008+Str(aPrazos[nX-1,2],5)+STR0021}) //"Venc. entre "###" e "###" dias"
			ElseiF nX > len(aPrazos)
				aadd(aRet,{'BR_BRANCO', STR0023+Str(aPrazos[nX-1,2],5) +STR0021}) //"Venc. faz menos de "###" dias"
			Endif
		Next
	Endif
	aadd(aRet,{"BR_VERDE", STR0024}) //"Nao vencidos"
	aadd(aRet,{"BR_VERMELHO", STR0025})                                         //"Baixados"
	BrwLegenda(STR0026, STR0027, aRet) //"Leyenda" //"Escala de cores"###"Legenda"
Endif

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa650SetPrzบAutor   ณBruno Sobieski      บFecha ณ  18-05-08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os percentuais e periodos em um array,              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa650SetPrz(lRefaz)
Local nI := 1
Default lRefaz	:=	.F.
aPrazos	:=	IIf(lRefaz,Nil,aPrazos)

If aPrazos == Nil             
	Pergunte('FINA650002',.F.)
	aPrazos	:=	{}
	While  nI<20 .And. &('mv_par'+StrZero(nI,2)) > 0
		AAdd(aPrazos, {dDataBase-&('mv_par'+StrZero(nI,2)),&('mv_par'+StrZero(nI,2)),&('mv_par'+StrZero(nI+1,2))})
		nI += 2
	Enddo
	aSort(aPrazos,,,{|x,y| x[2]>y[2]})
Endif
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa650PePrzบAutor   ณBruno Sobieski     บFecha ณ  18-05-08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrgar as perguntas de prazo e percentual                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa650PePrz()
If Pergunte('FINA650002',.T.)
	Fa650SetPrz(.T.)
Endif
                   
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor   ณBruno Sobieski     บFecha ณ  18-05-08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()
Local aRotina := { { OemToAnsi(STR0028), "axPesqui" , 0 , 1},; //"Pesquisar" //"Busqueda" //"Pesquisa"
{ OemToAnsi(STR0029)		, "FA650PEPRZ" 	, 0 , 3},; //"Visualizar" //"Visualizar" //"Percentuais"
{ OemToAnsi(STR0030)		, "AxVisual" 		, 0 , 2},; //"Visualizar" //"Visualizar" //"Vis. Titulo"
{ OemToAnsi(STR0031)		, "FA650VProv" 	, 0 , 2},; //"Visualizar" //"Visualizar" //"Vis. Provis."
{ OemToAnsi(STR0032)	, "Fa650Gera" 	, 0 , 3},; //"Visualizar" //"vis. Dif. cambio" //"Gerar provisao"
{ OemToAnsi(STR0027)	, "Fa650Leg",0 , 6} } //"Le&genda" //"Leyenda" //"Legenda"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPerc   บAutor   ณBruno Sobieski     บFecha ณ  18-05-08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega o percentual drovisao apra uma data                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC Function GetPerc(dData)
Local nX	:=	1      
Local nPerc := 	0
While nX <= Len(aPrazos)
	If dData < aPrazos[nX,1]
		nPerc	:=	aPrazos[nX,3]
		Exit
	EndIf
	nX++
Enddo		

Return nPerc
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetSeq    บAutor   ณBruno Sobieski     บFecha ณ  18-05-08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega a proxima sequencia de provisa                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetSeq(aProvisao)
Local cAliasQry1 := GetNextAlias()
Local cRet	:=	""
	BeginSql Alias cAliasQry1
	SELECT MAX(FIA_SEQ) FIA_SEQ
	FROM %table:FIA% FIA
	WHERE FIA_FILIAL = %xFilial:FIA%
          AND  FIA_PREFIX 	= %exp:aProvisao[1]% 
          AND  FIA_NUM   	= %exp:aProvisao[2]% 
          AND  FIA_PARCEL  	= %exp:aProvisao[3]% 
          AND  FIA_TIPO   	= %exp:aProvisao[4]% 
          AND  FIA_CLIENT 	= %exp:aProvisao[5]% 
          AND  FIA_LOJA		= %exp:aProvisao[6]% 
  		  AND FIA.%NotDel%
	EndSql

If Empty(FIA_SEQ)
	cRet	:=	"001"
Else
 	cRet	:=	Soma1(FIA_SEQ)
Endif	          
DbCloseArea()            
Return cRet
