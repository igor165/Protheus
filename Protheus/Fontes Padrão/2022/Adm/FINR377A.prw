#Include 'Protheus.ch'
#Include 'FINR377A.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINR377A
função para impressão do relatório de apuração de inss do contas a receber


@author Pâmela Bernardo
@since 06/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------

Function FINR377A()

//Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição de layout do relatório 


@author Pâmela Bernardo
@since 06/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------

Static Function ReportDef()

Local oReport 		:= NIL
Local oTitulo 	   	:= NIL
Local oTotal		:= NIL
Local oCell			:= NIL
Local nTam 			:= 0
Local cPictTit		:= PesqPict("SE1","E1_VALOR")


oReport := TReport():New("FINR377A","Relatório Acerto INSS CR","", {|oReport| PrintReport(oReport)},STR0001)//"Relátório irá trazer os títulos analítico selecionados no acerto de INSS de contas a receber" 
oReport:SetTotalInLine(.F.)
oReport:SetEdit(.F.)//-- Desabilitado botao personalizar, se o usuario incluir campo numerico nao eh possivel totalizar corretamente,
                    //--  segundo Framework teria de reescrever o relatorio.                   

oTitulo := TRSection():New(oReport,STR0002,{"SE1"},{OemToAnsi(STR0002)})  // "Cliente/Loja" 

nTam:= TAMSX3("E1_FILIAL")[1]
TRCell():New(oTitulo,"E1_FILIAL" 	,"SE1"		,STR0003,/*Picture*/		,nTam/*Tamanho*/,/*lPixel*/,) //"Filial"    
nTam:= TAMSX3("E1_PREFIXO")[1]
TRCell():New(oTitulo,"E1_PREFIXO" 	,"SE1"		,STR0004,/*Picture*/		,nTam/*Tamanho*/,/*lPixel*/,) //"Prefixo"
nTam:= TAMSX3("E1_NUM")[1]+1
TRCell():New(oTitulo,"E1_NUM" 		,"SE1"		,STR0005,/*Picture*/		,nTam/*Tamanho*/,/*lPixel*/,) //"Número"    
nTam:= TAMSX3("E1_PARCELA")[1]+3
TRCell():New(oTitulo,"E1_PARCELA"	,"SE1"		,STR0006,			 		,nTam)	//"Parcela"
nTam:= TAMSX3("E1_TIPO")[1]+1
TRCell():New(oTitulo,"E1_TIPO"    	,"SE1"		,STR0007,					,nTam)	//"Tipo"     
nTam:= TAMSX3("E1_EMISSAO")[1]
TRCell():New(oTitulo,"E1_EMISSAO"  	,"SE1"      ,STR0010,					,nTam) //"Emissao"    
TRCell():New(oTitulo,"E1_VENCTO"  	,"SE1"      ,STR0011,					,nTam) //"Vencimento"    
TRCell():New(oTitulo,"E1_VENCREA"	,"SE1"		,STR0012,					,nTam) //"Vencto Real"
nTam:= TAMSX3("E1_BASEINS")[1]
TRCell():New(oTitulo,"E1_BASEINS"   ,"SE1" 	  	,STR0013,cPictTit			,nTam) //"Base INSS"    
nTam:= TAMSX3("E1_INSS")[1]
TRCell():New(oTitulo,"E1_INSS"     	,"SE1" 	  	,STR0014,cPictTit			,nTam) //"INSS Abatido"  
nTam:= TAMSX3("E1_INSS")[1]
TRCell():New(oTitulo,"VALOR"      	, 	  	 	,STR0015,cPictTit			,nTam) //"Valor de Acerto"  

//oTitulo:SetHeaderSection(.T.)
// seção de totais do cliente
oTotal := TRSection():New(oTitulo,STR0016,{"SE1"})	//"Total Cliente"
oTotal:SetHeaderSection(.F.)	//Imprime o cabeçalho da secao
nTam:= TAMSX3("E1_NOMCLI")[1]+1
TRCell():New(oTotal,"E1_NOMCLI"    	,"SE1"		,STR0008,		, nTam)	//"Cliente"   */
nTam:= TAMSX3("E1_BASEINS")[1]
TRCell():New(oTotal,"TOTBASE"      	, 	  	  	,STR0013,cPictTit,nTam) //"Base INSS"    
nTam:= TAMSX3("E1_INSS")[1]
TRCell():New(oTotal,"TOTINS"      	, 	  	  	,STR0014,cPictTit,nTam) //"INSS Abatido"  
nTam:= TAMSX3("E1_INSS")[1]
TRCell():New(oTotal,"TOTDIF"      	, 	  	  	,STR0015,cPictTit,nTam) //"Valor de Acerto"  

 
oTitulo:SetAutoSize()
oTotal:SetAutoSize()

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Rotina de Impressão de dados     


@author Pâmela Bernardo
@since 06/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport)
Local oTitulo		:= oReport:Section(1)
Local oTotal		:= oReport:Section(1):Section(1)
Local nDif			:= 0
Local nTotBase		:= 0
Local nTotIns		:= 0
Local nTotDif		:= 0
Local cQuery		:= ""
Local nPos			:= 0
Local cChaveCli		:= ""
Local nCont			:= 0
Local nx			:= 0
Local nSE1Recno		:= 0
Local aRecProc		:= {}

dbSelectArea("FKG")
dbSelectArea("SE1")


oTitulo:Cell("VALOR"  	):SetBlock({||nDif})   

oTotal:SetLineStyle(.T.)
oTotal:Cell("TOTBASE"):SetBlock({||nTotBase })
oTotal:Cell("TOTINS"):SetBlock({||nTotIns }) 
oTotal:Cell("TOTDIF"):SetBlock({||nTotDif })  


oReport:SetTitle(STR0017)//"Acertos de INSS Contas a Receber"
oReport:SetMeter(RecCount())
oReport:IncMeter()
oTitulo:Init()
	If !oReport:Cancel()
		cChaveCli := aRecnoFKG[1][1]
		nDif := 0
		For nx:=1 to Len(aRecnoFKG)
 			If !Empty(aRecnoFKG[nx][3])
 				SE1->(dBGoto(aRecnoFKG[nx][4]))
				nSE1Recno:= SE1->(Recno())
				If aRecnoFKG[nx][1] == cChaveCli 
					If Ascan(aRecProc,aRecnoFKG[nx][4])== 0 //Tratamento para não duplicar o título
						Aadd(aRecProc, nSE1Recno)
						nPos:=  Ascan(aRecnoFKG, {|x|x[4]== nSE1Recno})
						If nPos>0
							For nCont:=1 to Len(aRecnoFKG)
								If nSE1Recno== aRecnoFKG[nCont][4]
									FKG->(dBGoto(aRecnoFKG[nCont][2]))
									If FKG->FKG_DEDACR=="1" //DEDUZ
										nDif -= FKG->FKG_VALOR
									Else
										nDif += FKG->FKG_VALOR
									EndIf
								Endif
							Next
							oTitulo:PrintLine()
							nDif := 0 
						 Endif	
					Endif
				Else
					nPos:=  Ascan(aCols3, {|x|x[1]  == cChaveCli})
					If nPos > 0 
						nTotBase	:= aCols3[nPos][3]
						nTotIns		:= aCols3[nPos][4]
						nTotDif		:= aCols3[nPos][5]
					Endif
					oTotal:Init()
					oTotal:PrintLine()
					oTotal:Finish()   
					cChaveCli := aRecnoFKG[nx][1]
					nx:= nx-1
				Endif
			Endif

		Next
		nPos:=  Ascan(aCols3, {|x|x[1]  == cChaveCli})
		If nPos > 0 .and. aCols3[nPos][5] <> 0
			nTotBase	:= aCols3[nPos][3]
			nTotIns		:= aCols3[nPos][4]
			nTotDif		:= aCols3[nPos][5]
		Endif
		oTotal:Init()
		oTotal:PrintLine()
		oTotal:Finish()  
		oTitulo:Finish() 
	Endif
Return