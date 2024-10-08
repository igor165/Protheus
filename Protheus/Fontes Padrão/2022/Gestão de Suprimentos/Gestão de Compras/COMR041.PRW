#INCLUDE "MATR130.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � COMR)$!  � Autor �Fabrica de Software    � Data �12/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da Rela��o de Divergencias de Pedidos de Compras   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � COMR041(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function COMR041()

Local oReport

//If FindFunction("TRepInUse") .And. TRepInUse()
	//����������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                �
	//������������������������������������������������������������������������
	oReport:= ReportDef()
 	oReport:PrintDialog()


Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ReportDef�Autor  �Fabrica de Software    �Data  �12/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da Rela��o de Divergencias de Pedidos de Compras   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oExpO1: Objeto do relatorio                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local cTitle   := STR0001 //"Relacao de Divergencias de Pedidos de Compras"
Local oReport 
Local oSection1
Local oSection2
Local oSection3

Local cAliasSD1 := GetNextAlias()
Local cAliasCOF := GetNextAlias()

//������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                   �
//� mv_par01 // a partir da data de recebimento                            �
//� mv_par02 // ate a data de recebimento                                  �
//� mv_par03 // Lista itens Pedido - Que constam na NF / todos os itens    �
//��������������������������������������������������������������������������
Pergunte("MTR130",.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:= TReport():New("COMR041",cTitle,"MTR130", {|oReport| ReportPrint(oReport,cAliasSD1,cAliasCOF)},STR0002+" "+STR0003) //"Emissao da Relacao de Itens para Compras com divergencias"
oReport:SetLandscape() 
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relatorio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de codigo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oSection1:= TRSection():New(oReport,STR0016,{"SD1","SF1","SA2","SB1"},/*aOrdem*/)
oSection1:SetHeaderPage()                                

TRCell():New(oSection1,"D1_DOC"    ,"SD1",/*Titulo*/,/*Picture*/,MAX(TamSX3("C7_NUM")[1],TamSX3("D1_DOC")[1]),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_EMISSAO","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_FORNECE","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_LOJA"   ,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A2_NOME"   ,"SA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_COD"    ,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_UM"     ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_QUANT"  ,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_VUNIT"  ,"SD1",/*Titulo*/,/*Picture*/,TamSX3("C7_PRECO")[1]+4,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F1_DTDIGIT","SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F1_COND"   ,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:= TRSection():New(oSection1,STR0017,{"SC7","SA2","SB1"}) 
oSection2:SetHeaderPage()

TRCell():New(oSection2,"C7_NUM"    ,"SC7",/*Titulo*/,/*Picture*/,MAX(TamSX3("C7_NUM")[1],TamSX3("D1_DOC")[1]),/*lPixel*/,/*{|| code-block de impressao }*/)   
TRCell():New(oSection2,"C7_EMISSAO","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"C7_FORNECE","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"C7_LOJA"   ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"A2_NOME"   ,"SA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"C7_PRODUTO","SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B1_UM"     ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"C7_QUANT"  ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"VALUNIT"   ,"   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValorSC7 })
TRCell():New(oSection2,"C7_DATPRF" ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"C7_COND"   ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)


oSection3:= TRSection():New(oSection2,"Divergencia",{"COF","COG"},,,,,,,,,,5) 
oSection3:SetHeaderPage()

TRCell():New(oSection3,"COG_CODIGO","COG",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COF_DESCRI","COF",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Posicione("COF", 1, xFilial("COF") + COG->COG_CODIGO, "COF_DESCRI") })

oSection1:Cell("D1_FORNECE"):GetFieldInfo("C7_FORNECE")
oSection1:Cell("D1_QUANT"):GetFieldInfo("C7_QUANT")
oSection1:Cell("F1_DTDIGIT"):GetFieldInfo("C7_DATPRF")
oSection1:Cell("F1_COND"):GetFieldInfo("C7_COND")
oSection2:Cell("VALUNIT"):GetFieldInfo("C7_PRECO")
oSection2:Cell("VALUNIT"):SetSize(TamSX3("C7_PRECO")[1]+4)

oSection2:Cell("C7_EMISSAO"):HideHeader()
oSection2:Cell("C7_FORNECE"):HideHeader()
oSection2:Cell("C7_LOJA"):HideHeader()
oSection2:Cell("A2_NOME"):HideHeader()
oSection2:Cell("C7_PRODUTO"):HideHeader()
oSection2:Cell("B1_UM"):HideHeader()
oSection2:Cell("C7_QUANT"):HideHeader()
oSection2:Cell("VALUNIT"):HideHeader()
oSection2:Cell("C7_DATPRF"):HideHeader()
oSection2:Cell("C7_COND"):HideHeader()  

oSection3:Cell("COG_CODIGO"):HideHeader()
oSection3:Cell("COF_DESCRI"):HideHeader()

oSection1:SetNoFilter("SB1")
oSection1:SetNoFilter("SA2")
oSection1:SetNoFilter("SF1")
oSection2:SetNoFilter("SB1")
oSection2:SetNoFilter("SA2")
 
Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Fabrica de Software	�Data  �13/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da Rela��o de Divergencias de Pedidos de Compras   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAliasSD1, cAliasCOF)

Local oSection1  := oReport:Section(1) 
Local oSection2  := oReport:Section(1):Section(1)  
Local oSection3	 := oReport:Section(1):Section(1):Section(1)  
Local dDataSav   := ctod("")
Local aItPcNotNF := {}
Local cCondPagto := ""
Local cNumPcSD1  := ""
Local cItemPcSD1 := ""
Local cChave	 := ""

Local nExiste    := 0
Local nX         := 0
Local nlin		 := 0

Private nValorSC7:= 0

dbSelectArea("SC7")
dbSetOrder(1)

dbSelectArea("SF1")
dbSetOrder(1)

dbSelectArea("SD1")
dbSetOrder(1)

dbSelectArea("COF")
dbSetOrder(1)

dbSelectArea("COG")
dbSetOrder(1)


//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
#IFDEF TOP
	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �	
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)
	//������������������������������������������������������������������������Ŀ
	//�Query do relat�rio da secao 1                                           �
	//��������������������������������������������������������������������������
	oReport:Section(1):BeginQuery()	

	BeginSql Alias cAliasSD1

	SELECT DISTINCT D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM,D1_EMISSAO,D1_DTDIGIT,D1_QUANT,D1_VUNIT,
           D1_TIPODOC,D1_SERIREM,D1_REMITO,D1_ITEMREM,D1_PEDIDO,D1_ITEMPC,D1_TIPO,F1_FILIAL,F1_DOC,F1_SERIE,
           F1_FORNECE,F1_LOJA,F1_COND,F1_EMISSAO,F1_TIPO,F1_DTDIGIT 
	         	
	FROM %table:SD1% SD1, %table:SF1% SF1, %table:COG% COG
	
	WHERE D1_FILIAL = %xFilial:SD1% AND 
  		  D1_DTDIGIT >= %Exp:Dtos(mv_par01)% AND 
		  D1_DTDIGIT <= %Exp:Dtos(mv_par02)% AND 
	  	  D1_TIPO = 'N' AND
		  SD1.%NotDel% AND
		  F1_FILIAL = %xFilial:SF1% AND 
		  F1_DOC = D1_DOC AND
		  F1_SERIE = D1_SERIE AND
		  F1_FORNECE = D1_FORNECE AND
		  F1_LOJA = D1_LOJA AND
  		  SF1.%NotDel% AND
  		  F1_FILIAL = COG_FILIAL AND
		  F1_DOC = COG_DOC AND
		  F1_SERIE = COG_SERIE AND
		  F1_FORNECE = COG_FORNEC AND
		  F1_LOJA = COG_LOJA
		  
	ORDER BY %Order:SD1% 
			
	EndSql                       
	
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
    
#ELSE

	MakeAdvplExpr(oReport:uParam)

	cCondicao := 'D1_FILIAL=="' + xFilial("SD1")+ '".And.'
	cCondicao += 'D1_TIPO == "N" .And.'
	cCondicao += 'DTOS(D1_DTDIGIT)>="'+DTOS(mv_par01)+'".And.DTOS(D1_DTDIGIT)<="'+DTOS(mv_par02)+'"'

	oReport:Section(1):SetFilter(cCondicao,IndexKey())

#ENDIF 

TRPosition():New(oSection1,"SB1",1,{|| xFilial("SB1") + (cAliasSD1)->D1_COD })
TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA })

oReport:SetMeter(SD1->(LastRec()))
dbSelectArea(cAliasSD1)

If cPaisLoc == "BRA"
	
	While !oReport:Cancel() .And. !(cAliasSD1)->(Eof())
		
 		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
		
		dDataSav  := dDataBase
		dDataBase := (cAliasSD1)->D1_DTDIGIT
		
		cDoc := (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA
	    cChave := (cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA
		
		If mv_par03 == 2 .And. !Empty((cAliasSD1)->D1_PEDIDO)
			nExiste := aScan(aItPcNotNF,{|x| x[1] == (cAliasSD1)->D1_PEDIDO })
			If nExiste == 0
				dbSelectArea("SC7")
				dbSetOrder(14)
				If dbSeek(xFilEnt(xFilial("SC7"))+(cAliasSD1)->D1_PEDIDO,.F.)
					SA2->(dbSetOrder(1))
					SA2->(dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
					
					While SC7->C7_NUM == (cAliasSD1)->D1_PEDIDO
						aadd(aItPcNotNF,{ SC7->C7_NUM,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_ITEM,SC7->C7_PRODUTO,;
						SA2->A2_NOME,SC7->C7_COND,SC7->C7_EMISSAO,;
						SC7->C7_UM,SC7->C7_QUANT,SC7->C7_PRECO,SC7->C7_DATPRF })
						dbSelectArea("SC7")
						dbSkip()
					EndDo
				EndIf
			Endif
		EndIf
		
		dbSelectArea("SC7")
		SC7->(dbSetOrder(19))       
		If dbSeek(xFilEnt(xFilial("SC7"))+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC,.F.)
			nValorSC7 := IIf(Empty(SC7->C7_REAJUSTE),xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,(cAliasSD1)->D1_EMISSAO,TamSX3("C7_PRECO")[2],SC7->C7_TXMOEDA),Formula(SC7->C7_REAJUSTE))
			
			#IFDEF TOP
				cCondPagto := (cAliasSD1)->F1_COND
			#ELSE
				SF1->(dbSetOrder(1))
				SF1->(MsSeek(xFilial("SF1") + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA ))
				cCondPagto := SF1->F1_COND
			#ENDIF
			
			If SC7->C7_COND  <> cCondPagto .Or. SC7->C7_DATPRF <> (cAliasSD1)->D1_DTDIGIT .Or. ;
				SC7->C7_QUANT <> (cAliasSD1)->D1_QUANT .Or. nValorSC7 <> (cAliasSD1)->D1_VUNIT
				
				oSection1:Init()
				oSection1:PrintLine()
				oSection2:Init()
				oSection2:PrintLine()
				
				oReport:PrintText("Divergencias", , 100)
				dbSelectArea("COG")
				COG->(dbSetOrder(1))
				
				dbSeek(cChave)
				
				Do While !EOF() .And. COG->(COG_FILIAL + COG_DOC + COG_SERIE + COG_FORNEC + COG_LOJA) == cChave 
					oSection3:Init()
					oSection3:PrintLine()
					COG->(DbSkip())
				EndDo
				oReport:SkipLine()
				oReport:FatLine()
								
				oSection1:Finish()
			EndIf
			
			If mv_par03 == 2 .And. !Empty((cAliasSD1)->D1_PEDIDO)
				nExiste := ascan(aItPcNotNF,{|x| x[1]+x[2]+x[3]+x[4]+x[5]==SC7->C7_NUM+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_ITEM+SC7->C7_PRODUTO})
				If nExiste > 0
					aDel(aItPcNotNF,nExiste)
					aSize(aItPcNotNF,len(aItPcNotNF)-1)
				EndIf
			EndIf
			
		Else
			
			oSection1:Init()
			oSection1:PrintLine()
			oReport:PrintText(STR0010,, 15 /*oSection1:Cell("D1_DOC"):ColPos()*/) // "Nao ha' pedido de compra colocado"
			oReport:SkipLine()
			oReport:PrintText("Divergencias", , 100)
			
			dbSelectArea("COG")
			COG->(dbSetOrder(1))
			
			dbSeek(cChave)
			
			Do While !EOF() .And. COG->(COG_FILIAL + COG_DOC + COG_SERIE + COG_FORNEC + COG_LOJA) == cChave 
				oSection3:Init()
				oSection3:PrintLine()
				COG->(DbSkip())
			EndDo
			oReport:SkipLine()
			oReport:FatLine()
		
			oSection1:Finish()
			
		EndIf
		
		dDataBase := dDataSav
		
		dbSelectArea(cAliasSD1)
		dbSkip()
		
		If mv_par03 == 2 .And. cDoc <> (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA
			
			If Len(aItPcNotNF) > 0
				
				oReport:FatLine()
				oReport:PrintText(STR0015+" "+Substr(cDoc,1,6),,oSection1:Cell("D1_DOC"):ColPos()) // "Itens do(s) pedido(s) que nao constam na Nota Fiscal "
				
				For nX :=1 to Len(aItPcNotNF)
					
					oReport:PrintText(aItPcNotNF[nX,01]+" "+aItPcNotNF[nX,04]+"  "+dtoc(aItPcNotNF[nX,08])+space(6)+;
					aItPcNotNF[nX,02]+space(08)+aItPcNotNF[nX,03]+space(05)+aItPcNotNF[nX,06]+space(11)+;
					aItPcNotNF[nX,05]+space(05)+aItPcNotNF[nX,09]+space(08)+TransForm(aItPcNotNF[nX,10],PesqPictQt("C7_QUANT",12))+;
					space(05)+TransForm(aItPcNotNF[nX,11],PesqPictQt("C7_PRECO",14))+space(05)+dtoc(aItPcNotNF[nX,12])+;
					space(07)+aItPcNotNF[nX,07],,oSection1:Cell("D1_DOC"):ColPos())
					
				Next nX
				
				oReport:FatLine()
				oReport:SkipLine()
				
				aItPcNotNF := {}
				
			EndIf
			
		EndIf
		
	EndDo
	
Else
	
	While !oReport:Cancel() .And. !(cAliasSD1)->(Eof())
		
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
		
		If IsRemito(1,(cAliasSD1)+"->D1_TIPODOC")
			dBSkip()
			Loop
		Endif
		
		If !Empty((cAliasSD1)->D1_REMITO)

			aArea := GetArea()
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek(xFilial("SD1")+ (cAliasSD1)->D1_REMITO + (cAliasSD1)->D1_SERIREM + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA + (cAliasSD1)->D1_COD + (cAliasSD1)->D1_ITEMREM )
			cNumPcSD1  := SD1->D1_PEDIDO
			cItemPcSD1 := SD1->D1_ITEMPC
			RestArea(aArea)

		Else
			cNumPcSD1  := (cAliasSD1)->D1_PEDIDO
			cItemPcSD1 := (cAliasSD1)->D1_ITEMPC
		Endif
		
		dDataSav  := dDataBase
		dDataBase := (cAliasSD1)->D1_DTDIGIT
		
		cDoc := (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA
		
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
		If dbSeek(xFilial("SC7")+cNumPcSD1+cItemPcSD1)
			
			nValorSC7 := IIf(Empty(SC7->C7_REAJUSTE),xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,(cAliasSD1)->D1_EMISSAO,TamSX3("C7_PRECO")[2],SC7->C7_TXMOEDA),Formula(SC7->C7_REAJUSTE))
			
			#IFDEF TOP
				cCondPagto := (cAliasSD1)->F1_COND
			#ELSE
				SF1->(dbSetOrder(1))
				SF1->(MsSeek(xFilial("SF1") + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA ))
				cCondPagto := SF1->F1_COND
			#ENDIF
			
			If SC7->C7_COND  <> cCondPagto .Or. SC7->C7_DATPRF <> (cAliasSD1)->D1_DTDIGIT .Or. ;
				SC7->C7_QUANT <> (cAliasSD1)->D1_QUANT .Or. nValorSC7 <> (cAliasSD1)->D1_VUNIT
				
				oSection1:Init()
				oSection1:PrintLine()
				oSection2:Init()
				oSection2:PrintLine()
				
				oSection1:Finish()
			EndIf
			
		Else
			
			oSection1:Init()
			oSection1:PrintLine()
			oReport:PrintText(STR0010,,oSection1:Cell("D1_DOC"):ColPos()) // "Nao ha' pedido de compra colocado"
			oSection1:Finish()
			
		EndIf
		
		dDataBase := dDataSav
		
		dbSelectArea(cAliasSD1)
		dbSkip()
		
	EndDo
	
EndIf

oSection2:Finish()	

Return Nil
