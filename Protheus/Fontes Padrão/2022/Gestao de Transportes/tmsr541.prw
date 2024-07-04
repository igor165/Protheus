#INCLUDE "TMSR541.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR541  � Autor � Katia                 � Data � 22/07/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Conciliacao de Sobras e Faltas                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR541()

Local oReport
Local aArea := GetArea()

oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ReportDef� Autor � Katia                 � Data � 22/07/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR541                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local aOrdem     := {}
Local cAliasQry  := GetNextAlias()
Local aRetBox    := RetSx3Box( Posicione('SX3', 2, 'DUU_IDRSP', 'X3CBox()' ),,, 1 )

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
oReport:= TReport():New("TMSR541",STR0001,"TMR541", {|oReport| ReportPrint(oReport,cAliasQry)},STR0002) // "Relat�rio de Concilia��o	
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)

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
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
Aadd( aOrdem, STR0004 ) //Tipo de Pendencia

oTipPnd := TRSection():New(oReport,STR0004,{"DYZ"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) 
oTipPnd:SetTotalInLine(.F.)

TRCell():New(oTipPnd,"DYZ_FILPND","DUU",STR0003 /*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTipPnd,"M0_FILIAL","SM0" ,"",/*Picture*/,60,/*lPixel*/,{|| Posicione("SM0",1,cEmpAnt+(cAliasQry)->DYZ_FILPND,"M0_FILIAL") })
TRCell():New(oTipPnd,"DYZ_TIPPND","DYZ",STR0004 /*cTitle*/,/*Picture*/,4 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTipPnd,"DYZ_DESPND","DYZ","" /*cTitle*/,/*Picture*/,20 /*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasQry+'->DYZ_TIPPND',.F.) },,,,,,.T.)

oPend := TRSection():New(oTipPnd,STR0003,{"DYZ","SA1","DYY","SM0"},/*Array com as Ordens*/,/*Campos do SX3*/,/*Campos do SIX*/) 
oPend:SetTotalInLine(.F.)
                          
TRCell():New(oPend,"DYZ_FILDOC"	,"DYZ",STR0005,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_DOC"   	,"DYZ",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_SERIE" 	,"DYZ",STR0006,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_NUMNFC"	,"DYZ",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_SERNFC" ,"DYZ",STR0006,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DT6_DATEMI"	,"DT6",STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DT6_CLIREM"	,"DT6",STR0008,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DT6_LOJREM"	,"DT6",STR0009,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DT6_NOMREM"	,"DT6",,/*Picture*/,17 /*Tamanho*/,/*lPixel*/,{ || Posicione("SA1",1,xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM,"A1_NOME")} /*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DT6_CLIDES"	,"DT6",STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DT6_LOJDES"	,"DT6",STR0009,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DT6_NOMDES"	,"DT6",,/*Picture*/,17 /*Tamanho*/,/*lPixel*/,{ || Posicione("SA1",1,xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES,"A1_NOME")} /*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DUY_DESCRI"	,"DUY",STR0011,/*Picture*/,20 /*Tamanho*/,/*lPixel*/,{ || Posicione("DUY",1,xFilial("DUY")+DT6->DT6_CDRDES,"DUY_DESCRI")} /*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DUY_EST"	,"DUY",STR0019,/*Picture*/,3 /*Tamanho*/,/*lPixel*/,{ || Posicione("DUY",1,xFilial("DUY")+DT6->DT6_CDRDES,"DUY_EST")} /*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_DATPND"	,"DYZ",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_NUMPND"	,"DYZ",STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_QTDOCO"	,"DYZ",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_QTDVOL"	,"DYZ",STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_QTDCON"	,"DYZ",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DYZ_DESMTC"	,"DYZ",STR0017,/*Picture*/,15 /*Tamanho*/,/*lPixel*/,{ || Posicione("DYY",1,xFilial("DYY")+(cAliasQry)->DYZ_CODMTC,"DYY_DESCRI")} /*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oPend,"DUU_DATRSP"	,"DUU",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,{ || Posicione("DUU",1,xFilial("DUU")+(cAliasQry)->DYZ_FILPND+(cAliasQry)->DYZ_NUMPND,"DUU_DATRSP")},,,,,,.F.)
TRCell():New(oPend,"DUU_IDRSP"	,"DUU",STR0020,/*Picture*/,10 /*Tamanho*/,/*lPixel*/,{ || AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == (cAliasQry)->DUU_IDRSP} ), 3 ]) },,,,,,.F.)


oPend:SetTotalInLine(.F.)

TRFunction():New(oPend:Cell("DYZ_QTDVOL"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPend:Cell("DYZ_QTDCON"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ReportPrin � Autor � Katia               � Data � 22/07/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR541                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry,cAliasQry2)

Local cTipVei := ''
Local cFroVei := ''
Local cCodVei := ''
Local cQuery  := '' 
Local cStaCon   :=""
Local cVazio	:= Space(Len(DUU->DUU_IDRSP))
Local cVazio2	:= Space(Len(DYZ->DYZ_STACON))
Local cQuery2   := ""                     
Local cTipPnd   := ""
Local cFilPnd   := ""
Local cTipPend   := ""


//---- Status da Conciliacao
If MV_PAR05 = 1 //Pendente
	cStaCon:= '1'
ElseIf MV_PAR05 = 2  //Conciliado
	cStaCon:= '3,4'		
ElseIf MV_PAR05 = 3  //Localizado
	cStaCon:= '2'				
ElseIf MV_PAR05 = 4  //Encerrado
	cStaCon:= '5'					
EndIf	

If mv_par10 == 2 //--Sintetico
	oReport:Section(1):Section(1):Hide()
EndIf

//---- Parametros
cQuery :="%"
If MV_PAR05 <> 5  //Todos  - Status Concilia��o
	cQuery += " AND DYZ_STACON IN (" + %Exp:cStaCon% + ") "   
Else
	cQuery += " AND DYZ_STACON <> '" + %Exp:cVazio2% + "' "  
EndIf                                                    

If MV_PAR08 <> 3  //Todos - Status Atr.Responsabilidade
	If MV_PAR08 == 1                
		cQuery += " AND DUU_IDRSP =  '" + %Exp:cVazio% + "' "
	ElseIf MV_PAR08 == 2                                    
		cQuery += " AND DUU_IDRSP <> '" + %Exp:cVazio% + "' "
	EndIf       
EndIf	
cQuery +="%"       

//-- Tipo de Pendencia
If MV_PAR09 == 1   //Falta
	cTipPnd:= StrZero(1,Len(DYZ->DYZ_TIPPND))
ElseIF MV_PAR09 == 2  //Sobra
	cTipPnd:= StrZero(3,Len(DYZ->DYZ_TIPPND))
Else  
	cTipPnd:= StrZero(1,Len(DYZ->DYZ_TIPPND)) + "' , '" + StrZero(3,Len(DYZ->DYZ_TIPPND))
EndIf


//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio, Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry                                           

	SELECT DYZ_FILIAL, DYZ_FILPND, DYZ_NUMPND, DYZ_FILDOC, DYZ_DOC, DYZ_SERIE,  DYZ_NUMNFC, DYZ_SERNFC, DYZ_CODMTC, 
		 DYZ_TIPPND,  DYZ_DATPND,  DYZ_QTDOCO, DYZ_QTDCON, DYZ_QTDVOL, DUU_IDRSP, DUU_DATRSP
	FROM %table:DYZ% DYZ    
	
	JOIN %table:DUU% DUU
	ON DUU_FILIAL = %xFilial:DUU%
	AND DUU_FILPND = DYZ_FILPND
	AND DUU_NUMPND = DYZ_NUMPND
	AND DUU.%NotDel%

	WHERE  DYZ_FILIAL = %Exp:FWxFilial('DYZ')%
           AND DYZ_FILPND BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% 
           AND DYZ_DATPND BETWEEN %Exp:Dtos(mv_par03)% AND %Exp:Dtos(mv_par04)% 			
           AND DYZ_CODMTC BETWEEN %Exp:mv_par06% AND %Exp:mv_par07% 
           AND DYZ_TIPPND IN (%Exp:cTipPnd%)
		   AND DYZ.%NotDel% 		   
   		%Exp:cQuery%
    	ORDER BY DYZ_FILPND, DYZ_TIPPND, DYZ_NUMPND, DYZ_FILDOC, DYZ_DOC, DYZ_SERIE, DYZ_NUMNFC, DYZ_SERNFC
EndSql 

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DYZ->(LastRec()))

TRPosition():New(oReport:Section(1):Section(1),"DT6",1,{|| xFilial("DT6")+(cAliasQry)->DYZ_FILDOC+(cAliasQry)->DYZ_DOC+(cAliasQry)->DYZ_SERIE })
TRPosition():New(oReport:Section(1):Section(1),"DUU",1,{|| xFilial("DUU")+(cAliasQry)->DYZ_NUMPND+(cAliasQry)->DYZ_FILPND})

//-- Utiliza a query do Pai
oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DYZ_FILPND+(cAliasQry)->DYZ_TIPPND == cParam },{ || (cAliasQry)->DYZ_FILPND+(cAliasQry)->DYZ_TIPPND  })

If mv_par10 == 1 //--Analitico
	oReport:Section(1):Print()
Else 
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		cFilOri := (cAliasQry)->DYZ_FILPND
		cViagem := (cAliasQry)->DYZ_TIPPND 

		oReport:Section(1):Init()
		oReport:Section(1):PrintLine()
                                 
		oReport:Section(1):Section(1):Init() 
		While !oReport:Cancel() .And. !(cAliasQry)->(Eof()) .And. (cAliasQry)->DYZ_FILPND == cFilOri ;
			.And. (cAliasQry)->DYZ_TIPPND == cViagem
				oReport:Section(1):Section(1):PrintLine()
				dbSelectArea(cAliasQry)
				dbSkip()
		EndDo   
		oReport:Section(1):Section(1):Finish()
	   	oReport:Section(1):Finish()
	EndDo
EndIf

oReport:SetMeter(DYZ->(LastRec()))

(cAliasQry)->(DbCloseArea())

Return
