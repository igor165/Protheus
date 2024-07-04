#INCLUDE "Protheus.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "LOJR851.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJR851   บAutor  ณVendas CRM          บ Data ณ  18/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio de Status de Lista de Presentes          		  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJR851 ()                                               

Local cPerg  := "LOJR851"												// grupo de perguntas
Local cAlias := GetNextAlias()											// area de trabalho

Local lLstPre   := SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND.;            //Valida se a funcionalidade esta ativa
					 IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)
Local oReport  															//Objeto do relatorio
Local oSection 															//Objeto Secao 2

Local cLegBonus:= Upper(LJR851TpMv("02",STR0026))						//legenda bonus
Local cLegBloqu:= Upper(LJR851X3Bx("3","ME4_TIPREG"))					//legenda bloqueio
Local cLegResga:= Upper(LJR851X3Bx("4","ME4_TIPREG"))					//legenda resgate

Local aSX3BxSta := {}													//array status
Local aSX3BxTip := {}													// array tipo

If !lLstPre
	MsgAlert(STR0001)//"O recurso de lista de presente nใo estแ ativo ou nใo foi devidamente aplicado e/ou configurado, impossํvel continuar!"
    Return .F.
Endif

#IFDEF TOP
		
	Pergunte(cPerg,.T.)
	
	//ฺฤฤฤฤฤฤฤฤฤฟ
	//ณRelatorioณ                                                              
	//ภฤฤฤฤฤฤฤฤฤู
	oReport:= TReport():New("LOJR851",STR0002, cPerg, {|oReport| PrintReport(oReport, cPerg, cAlias)})//"Status da Lista de Presentes"
	oReport:nFontBody   := 9
	oReport:nLineHeight := 50
	oReport:cFontBody   := "Arial"	
	
	oSection:= TRSection():New(oReport	, STR0003)//"Data do Evento"
	oSection:SetLineStyle(.T.)	
	oSection:SetHeaderBreak(.T.)			
	
	TRCell():New(oSection,"ME1_DTEVEN"	,,STR0003+Space(20-(Len(STR0003)))+".",,30,.T.,,"LEFT")//"Data do Evento"
	TRCell():New(oSection,"ME1_CODIGO"	,,STR0005+Space(20-(Len(STR0005)))+".",,30,.T.,,"LEFT")//"Lista"	
	TRCell():New(oSection,"ME3_DESCRI"	,,STR0004+Space(20-(Len(STR0004)))+".",,30,.T.,,"LEFT")//"Tipo do Evento"				  				   		       			
	TRCell():New(oSection,"ME1_STATUS"	,,STR0006+Space(20-(Len(STR0006)))+".",,30,.T.,{||LJR851X3Bx((cAlias)->ME1_STATUS,"ME1_STATUS",@aSX3BxSta)},"LEFT")//"Status"
	TRCell():New(oSection,"ME1_TIPO"  	,,STR0007+Space(20-(Len(STR0007)))+".",,30,.T.,{||LJR851X3Bx((cAlias)->ME1_TIPO,"ME1_TIPO",@aSX3BxTip)},"LEFT")//"Tipo Lista"
	TRCell():New(oSection,"ME1_FILORI"	,,STR0008+Space(20-(Len(STR0008)))+".",,30,.T.,,"LEFT")//"Filial Lista"
	TRCell():New(oSection,"A3_NOME"		,,STR0009+Space(20-(Len(STR0009)))+".",,30,.T.,,"LEFT")//"Vendedor"
	TRCell():New(oSection,"A1_NOME"		,,STR0010+Space(20-(Len(STR0010)))+".",,30,.T.,,"LEFT")//"Organizador"
	TRCell():New(oSection,"ME1_EMISSA"	,,STR0011+Space(20-(Len(STR0011)))+".",,30,.T.,,"LEFT")//"Abertura"
	TRCell():New(oSection,"VAZIO",,"",,100) 
	TRCell():New(oSection,"TOTAL_LISTA"	,,Upper(STR0012)+Space(20-(Len(STR0012)))+"."											,PesqPict("ME4","ME4_VALOR"),90,,,"LEFT")//"Valor da Lista"
	TRCell():New(oSection,"VENDIDO"		,,Upper(STR0013)+Space(20-(Len(STR0013)))+"."											,PesqPict("ME4","ME4_VALOR"),90,,,"LEFT")//"Vendas"	  		
	TRCell():New(oSection,"BONUS"		,,Padr(cLegBonus,20)+"."                                                         		,PesqPict("ME4","ME4_VALOR"),90,,,"LEFT")
	TRCell():New(oSection,"BLOQUEADO"	,,Padr(cLegBloqu,20)+"."                                                         		,PesqPict("ME4","ME4_VALOR"),90,,,"LEFT")
	TRCell():New(oSection,"RESGATADO"	,,Padr(cLegResga,20)+"."                                                         		,PesqPict("ME4","ME4_VALOR"),90,,,"LEFT")
	TRCell():New(oSection,"LIBERADO"	,,Upper(STR0014)+Space(20-(Len(STR0014)))+"."											,PesqPict("ME4","ME4_VALOR"),90,,{||(cAlias)->VENDIDO+(cAlias)->BONUS-(cAlias)->BLOQUEADO-(cAlias)->RESGATADO},"LEFT")//"Saldo"
	
	//ฺฤฤฤฤฤฤฟ
	//ณTotaisณ
	//ภฤฤฤฤฤฤู				

	TRFunction():New(oSection:Cell("TOTAL_LISTA")	,NIL,"SUM",,Upper(STR0015)+Space(40-(Len(STR0015)))+"."											,,,.F.,.T.,.F.)//"Valor das Listas"  
	TRFunction():New(oSection:Cell("VENDIDO")		,NIL,"SUM",,Upper(STR0013)+Space(40-(Len(STR0013)))+"."											,,,.F.,.T.,.F.)//"Vendas"  
	TRFunction():New(oSection:Cell("BONUS")			,NIL,"SUM",,Padr(cLegBonus,40)+"."	                                                        	,,,.F.,.T.,.F.)  
	TRFunction():New(oSection:Cell("BLOQUEADO")		,NIL,"SUM",,Padr(cLegBloqu,40)+"."                                                          	,,,.F.,.T.,.F.)  
	TRFunction():New(oSection:Cell("RESGATADO")		,NIL,"SUM",,Padr(cLegResga,40)+"."                                                          	,,,.F.,.T.,.F.)  
	TRFunction():New(oSection:Cell("LIBERADO")		,NIL,"SUM",,Upper(STR0014)+Space(40-(Len(STR0014)))+"."											,,,.F.,.T.,.F.)//"Saldo"  
		   		
	oReport:PrintDialog()

#ELSE
	MsgStop (STR0016)//"Relat๓rio incompatํvel para este tipo de banco de dados !"

#ENDIF

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor  ณLeandro Nogueira   บ Data ณ  18/02/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSelecao dos itens a serem impressos                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oReport - Objeto do Relat๓rio							  บฑฑ
ฑฑบ			   cPerg   - Cadastro de Perguntas para o Filtro do Relat๓rio บฑฑ
ฑฑบ			   cAlias  - Area para o Select da Primeira Se็ใo - Cabe็alho บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJR850                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport, cPerg, cAlias)

Local oSection	 	:= oReport:Section(1)                          // Objeto da Secao
Local cEndQuery		:= ""                                          	// Complemento da Query executada no banco  
Local cOrder		:= ""											// Order By
Local nTotListAtiv  := 0  											// total listas ativas
Local nTotListInAt  := 0  											// total listas inativas
Local nRow			:= 0											// Numero da Linha
Local nCol          := 0                                            // Numero da Coluna

Default oReport 	:= NIL
Default cPerg		:=""
Default cAlias		:=""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Data do Evento  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(MV_PAR01)//Data De:
   	cEndQuery += " AND ME1_DTEVEN >= '" + DToS(MV_PAR01) + "' "
EndIf

If !Empty(MV_PAR02)//Data At้:
	cEndQuery += " AND ME1_DTEVEN <= '" + DToS(MV_PAR02) + "' "
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Tipo do Evento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(MV_PAR03)
	cEndQuery += 	" AND ME1_TPEVEN = '" + MV_PAR03 + "' "           
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Status da Listaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If MV_PAR04 = 1 //Ativa                  
	cEndQuery += " AND ME1_STATUS = '1'"
ElseIf MV_PAR04 = 2 //Inativa 
   	cEndQuery += " AND ME1_STATUS = '2'"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametro - Ordem ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If MV_PAR05 == 1 //Data do Evento
	cEndQuery += " ORDER BY ME1_DTEVEN,ME1_CODIGO "
Else//Tipo de Evento
	cEndQuery += " ORDER BY ME3_DESCRI,ME1_CODIGO "
EndIf
cEndQuery	+= cOrder"
cEndQuery	:= "%"+cEndQuery+"%"

MakeSqlExpr(cPerg) 



BEGIN REPORT QUERY oSection
	BeginSQL alias cAlias    

	SELECT
		ME1_DTEVEN,
   		ME1_CODIGO,
   		ME1_TPEVEN,
		ME3_DESCRI,
		ME1_TIPO,
		ME1_FILORI,
		A3_NOME,
		A1_NOME,
		ME1_EMISSA,	
		ME1_STATUS,
		(SELECT SUM(ME2_VALUNI*ME2_QTDSOL)
			FROM %table:ME2% ME2 
			WHERE  ME2.ME2_CODIGO = ME1.ME1_CODIGO AND ME2.%notDel%)
			AS TOTAL_LISTA,
		(SELECT SUM(ME4_VALOR)
			FROM %table:ME4% ME4 
			WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4_TIPO = '1' AND ME4.%notDel%)
			AS VENDIDO,
		(SELECT SUM(ME4_VALOR)
			FROM %table:ME4% ME4 
			WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4_TIPO = '2' AND ME4.%notDel%) 
			AS BONUS,
		(SELECT SUM(ME4_VALOR)
			FROM %table:ME4% ME4 
			WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4_TIPREG = '3' AND ME4.%notDel%) 
			AS BLOQUEADO,
		(SELECT SUM(ME4_VALOR)
			FROM %table:ME4% ME4 
			WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ( ME4_TIPO = '3' OR ME4_TIPO = '4' ) AND ME4.%notDel%) 
			AS RESGATADO,
		(SELECT SUM(ME4_VALOR)
			FROM %table:ME4% ME4 
			WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4_TIPREG = '1' AND ME4.%notDel%) 
			AS LIBERADO					
	FROM 
		%table:ME1% ME1
		INNER JOIN %table:ME3% ME3 ON ME3.ME3_CODIGO = ME1.ME1_TPEVEN AND ME3.%notDel%
 		INNER JOIN %table:SA1% SA1 ON SA1.A1_COD = ME1.ME1_CODCLI AND SA1.A1_LOJA = ME1.ME1_LOJCLI AND SA1.%notDel%
		INNER JOIN %table:SA3% SA3 ON SA3.A3_COD = ME1.ME1_VEND AND SA3.%notDel%
	WHERE
		ME1.%notDel% %Exp:cEndQuery%
		
	EndSql
END REPORT QUERY oSection

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณControle de impressaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTotListAtiv := 0   
nTotListInAt := 0   
nRow		 := 200

While !oReport:Cancel() .AND. (cAlias)->(!Eof()) //Regra de impressao
	oSection:Init() 
	oSection:PrintLine()

	(cAlias)->(DbSkip())	
	If !(cAlias)->(Eof())
 		oReport:SkipLine()	 	
 		oReport:ThinLine()
 	EndIf
	nRow := oReport:Row()
	nCol := 10
	oSection:Finish()
    If (cAlias)->ME1_STATUS='2'
		nTotListInAt := nTotListInAt + 1
    Else
		nTotListAtiv := nTotListAtiv + 1
    EndIf
EndDo  

oReport:PrintText(STR0023,nRow,nCol)			//"999999999999999"	"TOTAL LISTAS ATIVAS"
oReport:PrintText(transform(nTotListAtiv,STR0025),nRow,nCol+350)			//"999999999999999"
oReport:SkipLine()	 	
nRow := oReport:Row()
oReport:PrintText(STR0024,nRow,nCol)			//"999999999999999"   	"TOTAL LISTAS INATIVAS"
oReport:PrintText(transform(nTotListInat,STR0025),nRow,nCol+350)			//"999999999999999"
oReport:SkipLine()	 	

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR851X3BxบAutor  ณLeandro Noguira     บ Data ณ  25/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a descri็ใo do combo box do campo no SX3            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ cCodigo	- Codigo do combo								  บฑฑ
ฑฑบ          ณ cCampo	- campo a ser exibido							  บฑฑ
ฑฑบ          ณ aSX3Box 	- Box dos campos								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJR851                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR851X3Bx (cCodigo,cCampo,aSX3Box)

Local cRet  	:= ""  	//Retorno
Local nPos		:= 0   	//Posicao do array    

Default aSX3Box	:= {}	//Array de Opcoes do Combo Box
Default cCodigo	:= ""
Default cCampo	:= ""

If Len(aSX3Box)<=0
	If !Empty(Posicione("SX3", 2, cCampo, "X3CBox()" ))
		aSX3Box	:= RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, 1 )	
	Endif
Endif	
	 
If Len(	aSX3BOX ) > 0
	nPos := Ascan(aSX3BOX,{|x| x[2]== cCodigo})
	If nPos > 0 
		cRet:= aSX3Box[nPos,3]
	Endif
Endif	
	
If Empty(cRet)
	cRet := cCodigo
Endif

Return Rtrim(cRet) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR851TpMvบAutor  ณLeandro Noguira     บ Data ณ  25/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o tipo de movimento cadastrado na tabel ZI do SX5   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ cCodigo	- Codigo do combo								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJR848                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR851TpMv (cCodigo, cStrAltern)                                       
Local cRet  	:= ""  	//Retorno

DbSelectArea( "SX5" )
If DbSeek( xFilial("SX5")+"ZI"+cCodigo )
	cRet:= X5Descri()
Else
	If !Empty(cStrAltern)
		cRet:= cStrAltern
	EndIf
EndIf

If Empty(cRet)
	cRet := cCodigo
Endif

Return Rtrim(cRet)      
