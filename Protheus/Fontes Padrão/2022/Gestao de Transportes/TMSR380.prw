#INCLUDE "TMSR380.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR380  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime a Relacao de Veiculos a Liberar por Escala         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR380()

Local oReport
Local aArea := GetArea()

//--Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR380                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local aOrdem    := {}
Local cAliasQry := GetNextAlias()
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0

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
oReport:= TReport():New("TMSR380",STR0013,"TMR380", {|oReport| ReportPrint(oReport,cAliasQry)},STR0014) // "Relacao de Veiculos a Liberar por Escala" ### "Emite a Relacao de Veiculos a Liberar por Escala conforme os parametros informados"
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Filial Escala De ?                            �
//� mv_par02	 // Filial Escala Ate ?							        |
//� mv_par03	 // Data Chegada Ate ?							        |
//� mv_par04	 // Hora Chegada Ate ?							        |
//| mv_par05  Lista  1- Atrasado 			     				        |
//|					   2- Nao Atrasado    						        |
//|					   3- Ambos         							        |
//� mv_par06	 // Servico de Transp. ?                          �
//����������������������������������������������������������������
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
Aadd( aOrdem, STR0015 ) // "Fil.Atividade + Fil. Origem"

oFilAti := TRSection():New(oReport,STR0016,{"DTW"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Fil. Atividade"
oFilAti:SetTotalInLine(.F.)
TRCell():New(oFilAti,"DT6_FILORI","DT6",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilAti,"DES.FILIAL"," "  ,STR0017,/*Picture*/,15         ,/*lPixel*/, {|| Posicione("SM0",1,cEmpAnt+(cAliasQry)->DTW_FILATI,"M0_FILIAL") } )

oViagem := TRSection():New(oFilAti,STR0018,{"DTW","DTQ","DTR","DA3","DUP","DA4"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Viagem"
oViagem:SetTotalText(STR0030) //-- "Total de Viagem"
oViagem:SetTotalInLine(.F.)
TRCell():New(oViagem,"DTW_FILORI","DTW",STR0019,/*Picture*/,8          ,/*lPixel*/, {|| (cAliasQry)->DTW_FILORI } )
TRCell():New(oViagem,"DTW_VIAGEM","DTW",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_FILDES","DTQ",STR0020,/*Picture*/,8          ,/*lPixel*/, {|| (cAliasQry)->DTQ_FILDES } )
TRCell():New(oViagem,"DTW_DATREA","DTW",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTW_HORREA","DTW",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTW_DATPRE","DTW",STR0023,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| TMR380Prv((cAliasQry)->DTW_DATPRE,(cAliasQry)->DTW_HORPRE,(cAliasQry)->DTW_DATREA,(cAliasQry)->DTW_HORREA,1) } )
TRCell():New(oViagem,"DTW_HORPRE","DTW",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| TMR380Prv((cAliasQry)->DTW_DATPRE,(cAliasQry)->DTW_HORPRE,(cAliasQry)->DTW_DATREA,(cAliasQry)->DTW_HORREA,2) } )
TRCell():New(oViagem,"DTR_CODVEI","DTR",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"PLACAVEI"  ,""   ,STR0026,/*Picture*/,TamSx3("DA3_PLACA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTR_CODRB1","DTR",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"PLACARB1"  ,""   ,STR0026,/*Picture*/,TamSx3("DA3_PLACA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTR_CODRB2","DTR",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"PLACARB2"  ,""   ,STR0026,/*Picture*/,TamSx3("DA3_PLACA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
If lTercRbq
	TRCell():New(oViagem,"DTR_CODRB3","DTR",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oViagem,"PLACARB3"  ,""   ,STR0026,/*Picture*/,TamSx3("DA3_PLACA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf
TRCell():New(oViagem,"DA4_NREDUZ","DA4",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oTotaliz := TRFunction():New(oViagem:Cell("DTW_VIAGEM"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilAti)
oTotaliz:SetCondition({ || TMR380Vge((cAliasQry)->DTW_FILORI,(cAliasQry)->DTW_VIAGEM,,(cAliasQry)->DTW_FILATI) })

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)

Local cAtivChg := GetMV("MV_ATIVCHG") // Parametro usado para filtrar o DTW
Local cWhere   := ''
Local cSerTms  := Alltrim(Str(mv_par06))
Local cCodRb3  := ''
Local cPlacaRb3 := ''
Local lTercRbq := DTR->(ColumnPos("DTR_CODRB3")) > 0

If lTercRbq
	cCodRb3   := "%DTR_CODRB3%"
	cPlacaRb3 := "%DA3D.DA3_PLACA PLACARB3%"
EndIf 

cWhere := "%"
If cSerTms <> '4' 
	cWhere += " AND DTW_SERTMS = '"+cSerTms+"' "
EndIf	
cWhere += "%"

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DTW_FILIAL, DTW_FILORI, DTW_VIAGEM, DTQ_FILDES, DTW_DATREA, DTW_HORREA,
	       DTW_DATPRE, DTW_HORPRE, DTR_CODVEI, DA3A.DA3_PLACA PLACAVEI, DTR_CODRB1, 
	       DA3B.DA3_PLACA PLACARB1, DTR_CODRB2, DA3C.DA3_PLACA PLACARB2,%Exp:cCodRb3%,%Exp:cPlacaRb3%, DUP_CODMOT,
	       DA4_NREDUZ, DTW_FILATI
	  FROM %table:DTW% DTW
	  JOIN %table:DTQ% DTQ
	    ON DTQ_FILIAL = %xFilial:DTQ%
	    AND DTQ_FILORI = DTW_FILORI
	    AND DTQ_VIAGEM = DTW_VIAGEM
	    AND DTQ.%NotDel%
	  LEFT JOIN %table:DTR% DTR
	    ON DTR_FILIAL = %xFilial:DTR%
	    AND DTR_FILORI = DTQ_FILORI
	    AND DTR_VIAGEM = DTQ_VIAGEM
	    AND DTR.%NotDel%
	  LEFT JOIN %table:DA3% DA3A
	    ON DA3A.DA3_FILIAL = %xFilial:DA3%
	    AND DA3A.DA3_COD = DTR_CODVEI
	    AND DA3A.%NotDel%
	  LEFT JOIN %table:DA3% DA3B
	    ON DA3B.DA3_FILIAL = %xFilial:DA3%
	    AND DA3B.DA3_COD = DTR_CODRB1
	    AND DA3B.%NotDel%
	  LEFT JOIN %table:DA3% DA3C
	    ON DA3C.DA3_FILIAL = %xFilial:DA3%
	    AND DA3C.DA3_COD = DTR_CODRB2
	    AND DA3C.%NotDel%
	  LEFT JOIN %table:DA3% DA3D
	    ON DA3D.DA3_FILIAL = %xFilial:DA3%
	    AND DA3D.DA3_COD = %Exp:cCodRb3%
	    AND DA3D.%NotDel%
	  LEFT JOIN %table:DUP% DUP
	    ON DUP_FILIAL = %xFilial:DUP%
	    AND DUP_FILORI = DTQ_FILORI
	    AND DUP_VIAGEM = DTQ_VIAGEM
	    AND DUP_CODVEI = DTR_CODVEI
	    AND DUP.%NotDel%
	  LEFT JOIN %table:DA4% DA4
	    ON DA4_FILIAL = %xFilial:DA4%
	    AND DA4_COD = DUP_CODMOT
	    AND DA4.%NotDel%
	  WHERE DTW_FILIAL = %xFilial:DTW%
	    AND DTW_FILATI BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
	    AND DTW_DATREA <= %Exp:Dtos(mv_par03)% 
	    AND DTW_HORREA <= %Exp:mv_par04%
	    AND DTW_TIPTRA = %Exp:StrZero(1,Len(DTW->DTW_TIPTRA))%
	    AND DTW_ATIVID = %Exp:cAtivChg%
	    AND DTW_STATUS = %Exp:StrZero(2,Len(DTW->DTW_STATUS))%
	    AND DTW.%NotDel% 
		%Exp:cWhere%
	ORDER BY DTW_FILIAL, DTW_FILATI, DTW_FILORI, DTW_VIAGEM
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
oReport:SetMeter(DTW->(LastRec()))

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DTW_FILATI == cParam },{ || (cAliasQry)->DTW_FILATI })

DbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		cFilAti := (cAliasQry)->DTW_FILATI
		//-- Verifica se dever� ser impresso "N�o Atrasado", "Atrasados" ou "Ambos"
		If TMR380Prv((cAliasQry)->DTW_DATPRE,(cAliasQry)->DTW_HORPRE,,,3)
			oReport:Section(1):Init()
			oReport:Section(1):PrintLine()
			oReport:Section(1):Section(1):Init()
			While !(cAliasQry)->(Eof()) .And. (cAliasQry)->DTW_FILATI == cFilAti
				cFilOri := (cAliasQry)->DTW_FILORI
				cViagem := (cAliasQry)->DTW_VIAGEM
				cCodVei := (cAliasQry)->DTR_CODVEI
				//-- Verifica se dever� ser impresso "N�o Atrasado", "Atrasados" ou "Ambos"
				If TMR380Prv((cAliasQry)->DTW_DATPRE,(cAliasQry)->DTW_HORPRE,,,3)
					oReport:Section(1):Section(1):PrintLine()
					(cAliasQry)->(DbSkip())
					While !(cAliasQry)->(Eof()) .And. 	(cAliasQry)->DTW_FILATI == cFilAti .And. ;
																	(cAliasQry)->DTW_FILORI == cFilOri .And. ;
																	(cAliasQry)->DTW_VIAGEM == cViagem   
						//-- Verifica se dever� ser impresso "N�o Atrasado", "Atrasados" ou "Ambos"
						If TMR380Prv((cAliasQry)->DTW_DATPRE,(cAliasQry)->DTW_HORPRE,,,3)
							oReport:Section(1):Section(1):Cell("DTW_FILORI"):Hide()
							oReport:Section(1):Section(1):Cell("DTW_VIAGEM"):Hide()
							oReport:Section(1):Section(1):Cell("DTQ_FILDES"):Hide()
							oReport:Section(1):Section(1):Cell("DTW_DATREA"):Hide()
							oReport:Section(1):Section(1):Cell("DTW_HORREA"):Hide()
							oReport:Section(1):Section(1):Cell("DTW_DATPRE"):Hide()
							oReport:Section(1):Section(1):Cell("DTW_HORPRE"):Hide()
							If cCodVei == (cAliasQry)->DTR_CODVEI
								oReport:Section(1):Section(1):Cell("DTR_CODVEI"):Hide()
								oReport:Section(1):Section(1):Cell("PLACAVEI"  ):Hide()
								oReport:Section(1):Section(1):Cell("DTR_CODRB1"):Hide()
								oReport:Section(1):Section(1):Cell("PLACARB1"  ):Hide()
								oReport:Section(1):Section(1):Cell("DTR_CODRB2"):Hide()
								oReport:Section(1):Section(1):Cell("PLACARB2"  ):Hide()
								If lTercRbq
									oReport:Section(1):Section(1):Cell("DTR_CODRB3"):Hide()
									oReport:Section(1):Section(1):Cell("PLACARB3"  ):Hide()
								EndIf
							Else
								oReport:Section(1):Section(1):Cell("DTR_CODVEI"):Show()
								oReport:Section(1):Section(1):Cell("PLACAVEI"  ):Show()
								oReport:Section(1):Section(1):Cell("DTR_CODRB1"):Show()
								oReport:Section(1):Section(1):Cell("PLACARB1"  ):Show()
								oReport:Section(1):Section(1):Cell("DTR_CODRB2"):Show()
								oReport:Section(1):Section(1):Cell("PLACARB2"  ):Show()
								If lTercRbq
									oReport:Section(1):Section(1):Cell("DTR_CODRB3"):Show()
									oReport:Section(1):Section(1):Cell("PLACARB3"  ):Show()
								EndIf
							EndIf
							oReport:Section(1):Section(1):PrintLine()
							oReport:Section(1):Section(1):Cell("DTW_FILORI"):Show()
							oReport:Section(1):Section(1):Cell("DTW_VIAGEM"):Show()
							oReport:Section(1):Section(1):Cell("DTQ_FILDES"):Show()
							oReport:Section(1):Section(1):Cell("DTW_DATREA"):Show()
							oReport:Section(1):Section(1):Cell("DTW_HORREA"):Show()
							oReport:Section(1):Section(1):Cell("DTW_DATPRE"):Show()
							oReport:Section(1):Section(1):Cell("DTW_HORPRE"):Show()
							oReport:Section(1):Section(1):Cell("DTR_CODVEI"):Show()
							oReport:Section(1):Section(1):Cell("PLACAVEI"  ):Show()
							oReport:Section(1):Section(1):Cell("DTR_CODRB1"):Show()
							oReport:Section(1):Section(1):Cell("PLACARB1"  ):Show()
							oReport:Section(1):Section(1):Cell("DTR_CODRB2"):Show()
							oReport:Section(1):Section(1):Cell("PLACARB2"  ):Show()
							If lTercRbq
								oReport:Section(1):Section(1):Cell("DTR_CODRB3"):Show()
								oReport:Section(1):Section(1):Cell("PLACARB3"  ):Show()
							EndIf
						EndIf
						cCodVei := (cAliasQry)->DTR_CODVEI
						(cAliasQry)->(DbSkip())
					EndDo
				Else
					(cAliasQry)->(DbSkip())
				EndIf
			EndDo
			oReport:Section(1):Finish()
			oReport:Section(1):Section(1):Finish()
		Else
			(cAliasQry)->(DbSkip())
		EndIf
		oReport:IncMeter()
	EndDo
EndIf

TMR380Vge(,,.T.) //-- Zera a variavel controladora do totalizador da viagem

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR380Vge � Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da soma do totalizador da viagem                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Filial Origem                                        ���
���          �ExpC2: Viagem                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR380Vge(cFilOri,cViagem,lZera,cFilAti)

Static  cVge    := ''
Local   lRet    := .T.
Default lZera   := .F.
Default cFilAti := ''

If lZera
	cVge := ''
Else
	If cVge == cFilAti + cFilOri + cViagem
		lRet := .F.
	EndIf
	cVge := cFilAti + cFilOri + cViagem
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR380Prv � Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a data/hora prevista                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD1: Data Prevista                                        ���
���          �ExpC1: Hora Prevista                                        ���
���          �ExpD2: Data Realizada                                       ���
���          �ExpC3: Hora Realizada                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR380Prv(dDataPrev,cHoraPrev,dDataReal,cHoraReal,nRet)

Local nHora := 0
Local lRet  := .T.
Default dDataReal := CtoD('')
Default cHoraReal := ''

If nRet <> 3
	nHora := SubtHoras( dDataPrev, cHoraPrev, dDataReal, cHoraReal)
	If nHora > 0
		SomaDiaHora(@dDataPrev, @cHoraPrev, nHora)
	EndIf
EndIf

If nRet == 1
	Return dDataPrev
ElseIf nRet == 2
	Return cHoraPrev
ElseIf nRet == 3
	If mv_par05 == 1
		lRet := ( dDataPrev >= dDataBase .And. cHoraPrev >= Left(StrTran(Time(),":",""),4) )
	ElseIf mv_par05 == 2
		lRet := ( dDataPrev < dDataBase .Or. cHoraPrev < Left(StrTran(Time(),":",""),4) )		
	EndIf
	Return lRet
EndIf

Return()