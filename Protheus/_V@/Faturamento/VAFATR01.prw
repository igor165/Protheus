#INCLUDE "MATR550.CH" 
#INCLUDE "Protheus.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MATR550  � Autor � Marco Bianchi         � Data � 05/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Notas Fiscais                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFAT - R4                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function VAFATR01()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	VAFAR01R3()
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Marco Bianchi         � Data �05/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport,oSintetico,oItens,oItensD1,oItensD2,oCabec,oCabecF1,oCabecF2,oTotDia
Local cAliasQry := GetNextAlias()
Local cNota 	:= ""
Local cSerie 	:= ""
Local nAcN1  	:= 0, nAcN2 := 0, nAcN3 := 0, nAcN4 := 0, nAcN5 := 0, nAcN6 := 0, nVlrISS := 0, nFretAut := 0
Local cCod		:= ""
Local cDesc		:= ""
Local cPedido	:= ""
Local cItem		:= ""
Local cRemito	:= ""
Local cItemrem	:= ""

Local nQuant	:= 0
Local nPrcVen	:= 0
Local nValadi	:= 0
Local cLocal	:= ""
Local cCF		:= ""
Local cTes		:= ""

Local cItemPV	:= ""
Local nValIPI	:= 0
Local nValIcm	:= 0
Local nValISS	:= 0
Local nDesAces	:= 0
Local nTotGer	:= 0

// Variaveis Base Localizacao
Local cCliente 		:= ""
Local cLoja			:= ""
Local cNome			:= ""
Local dEmissao 		:= CTOD("  /  /  ")
Local cTipo    		:= ""
Local nAcD1			:= 0
Local nAcD2			:= 0
Local nAcDImpInc	:= 0
Local nAcDImpNoInc	:= 0
Local nAcD3			:= 0
Local nAcD4       	:= 0
Local nAcD5       	:= 0
Local nAcD6       	:= 0
Local nAcD7       	:= 0
Local nAcDAdi		:= 0
Local nTotal 		:= 0
Local nImpInc 		:= 0
Local nImpnoInc 	:= 0
Local nTotcImp  	:= 0

Local nAcG1			:= 0
Local nAcG2			:= 0
Local nAcGAdi		:= 0
Local nAcGImpInc	:= 0
Local nAcGImpNoInc	:= 0
Local nAcG3			:= 0
Local nTotNeto		:= 0
Local nTotNetGer	:= 0
Local nIPIDesp 		:= 0
Local nICMDesp 		:= 0

Local nAcImpInc  	:= 0
Local nAcImpNoInc	:= 0

Local nTotDia		:= 0


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
oReport := TReport():New("MATR550",STR0030,"MTR550P9R1", {|oReport| ReportPrint(oReport,cAliasQry,oSintetico,oItens,oItensD1,oItensD2,oCabec,oCabecF1,oCabecF2,oTotDia)},STR0031)  // "Relacao de Notas Fiscais"###"Este programa ira emitir a relacao de notas fiscais."
oReport:SetLandscape(.T.) 

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
If cPaisLoc == "BRA"

	// Sintetico
	oSintetico := TRSection():New(oReport,STR0055,{"SF2","SD2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSintetico:SetTotalInLine(.F.)
	TRCell():New(oSintetico,"CNOTA"		,/*Tabela*/,RetTitle("D2_DOC")		,PesqPict("SD2","D2_DOC")		,TamSX3("D2_DOC")[1]	,/*lPixel*/,{|| cNota })
	TRCell():New(oSintetico,"CSERIE"	,/*Tabela*/,RetTitle("D2_SERIE")	,PesqPict("SD2","D2_SERIE")		,TamSX3("D2_SERIE")[1]	,/*lPixel*/,{|| cSerie })
	TRCell():New(oSintetico,"NACN1"		,/*Tabela*/,RetTitle("D2_QUANT")	,PesqPict("SD2","D2_QUANT")		,TamSX3("D2_QUANT")[1]	,/*lPixel*/,{|| nAcN1 },,,"RIGHT")
	TRCell():New(oSintetico,"NACN2"		,/*Tabela*/,STR0039					,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| nAcN2 },,,"RIGHT")
	TRCell():New(oSintetico,"NACN5"		,/*Tabela*/,RetTitle("D2_VALIPI")	,PesqPict("SD2","D2_VALIPI")	,TamSX3("D2_VALIPI")[1]	,/*lPixel*/,{|| nAcN5 },,,"RIGHT")
	TRCell():New(oSintetico,"NACN4"		,/*Tabela*/,RetTitle("D2_VALICM")	,PesqPict("SD2","D2_VALICM")	,TamSX3("D2_VALICM")[1]	,/*lPixel*/,{|| nAcN4 },,,"RIGHT")
	TRCell():New(oSintetico,"NVLRISS"	,/*Tabela*/,RetTitle("D2_VALISS")	,PesqPict("SD2","D2_VALISS")	,TamSX3("D2_VALISS")[1]	,/*lPixel*/,{|| nVlrISS },,,"RIGHT")
	TRCell():New(oSintetico,"NDESPACES"	,/*Tabela*/,STR0032					,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| nAcN3+nFretAut },,,"RIGHT")
	TRCell():New(oSintetico,"NACN6"		,/*Tabela*/,STR0033					,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| nAcN6 },,,"RIGHT")



    // Analitico
	oCabec := TRSection():New(oReport,STR0056,{"SF2","SD2","SA1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oCabec:SetTotalInLine(.F.)
	TRCell():New(oCabec,"F2_CLIENTE"	,/*Tabela*/,RetTitle("F2_CLIENTE")	,/*Picture*/,TamSX3("F2_CLIENTE")[1]+ 5,/*lPixel*/,{|| cCliente })
	TRCell():New(oCabec,"F2_LOJA"		,/*Tabela*/,RetTitle("F2_LOJA")		,/*Picture*/,/*Tamanho*/,/*lPixel*/,{||  cLoja})
	TRCell():New(oCabec,"A1_NOME"		,/*Tabela*/,RetTitle("A1_NOME")		,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cNome})
	TRCell():New(oCabec,"F2_EMISSAO"	,/*Tabela*/,RetTitle("F2_EMISSAO")	,/*Picture*/,TamSX3("F2_EMISSAO")[1]+ 5,/*lPixel*/,{||  dEmissao})
	TRCell():New(oCabec,"F2_TIPO"		,/*Tabela*/,RetTitle("F2_TIPO")		,/*Picture*/,/*Tamanho*/,/*lPixel*/,{||  cTipo })

	oItens := TRSection():New(oCabec,STR0057,{"SF2","SD2","SB1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oItens:SetTotalInLine(.F.)
	TRCell():New(oItens,"CCOD"			,/*Tabela*/,STR0035,/*Picture*/					,TamSX3("D2_COD"	)[1]	,/*lPixel*/,{|| cCod			})
	TRCell():New(oItens,"CDESC"			,/*Tabela*/,STR0036,/*Picture*/					,TamSX3("B1_DESC"	)[1]	,/*lPixel*/,{|| cDesc			})
	TRCell():New(oItens,"NQUANT"		,/*Tabela*/,STR0037,PesqPict("SD2","D2_QUANT")	,TamSX3("D2_QUANT"	)[1]	,/*lPixel*/,{|| nQuant			},,,"RIGHT")
	TRCell():New(oItens,"NPRCVEN"		,/*Tabela*/,STR0038,PesqPict("SD2","D2_PRCVEN")	,TamSX3("D2_PRCVEN"	)[1]	,/*lPixel*/,{|| nPrcVen			},,,"RIGHT")
	TRCell():New(oItens,"NTOTAL"		,/*Tabela*/,STR0039,PesqPict("SD2","D2_TOTAL")	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nTotal			},,,"RIGHT")
	TRCell():New(oItens,"CLOCAL"		,/*Tabela*/,STR0040,PesqPict("SD2","D2_LOCAL") ,TamSX3("D2_LOCAL"  )[1]	,/*lPixel*/,{|| cLocal			})
	TRCell():New(oItens,"CCF"			,/*Tabela*/,STR0041,PesqPict("SD2","D2_CF")    ,TamSX3("D2_CF" 	)[1]	,/*lPixel*/,{|| cCF				})
	TRCell():New(oItens,"CTES"	  		,/*Tabela*/,STR0042,PesqPict("SD2","D2_TES")   ,TamSX3("D2_TES"    )[1]	,/*lPixel*/,{|| cTes			})
	TRCell():New(oItens,"CPEDIDO"		,/*Tabela*/,STR0043,PesqPict("SD2","D2_PEDIDO"),TamSX3("D2_PEDIDO" )[1]	,/*lPixel*/,{|| cPedido			})
	TRCell():New(oItens,"CITEMPV"		,/*Tabela*/,STR0044,PesqPict("SD2","D2_ITEMPV"),TamSX3("D2_ITEMPV"	)[1]	,/*lPixel*/,{|| cItemPV			})
	TRCell():New(oItens,"NVALIPI"		,/*Tabela*/,STR0045,PesqPict("SD2","D2_VALIPI")	,TamSX3("D2_VALIPI"	)[1]	,/*lPixel*/,{|| nValIpi			},,,"RIGHT")
	TRCell():New(oItens,"NVALICM"		,/*Tabela*/,STR0046,PesqPict("SD2","D2_VALICM")	,TamSX3("D2_VALICM"	)[1]	,/*lPixel*/,{|| nValIcm			},,,"RIGHT")
	TRCell():New(oItens,"NVALISS"		,/*Tabela*/,STR0047,PesqPict("SD2","D2_VALISS")	,TamSX3("D2_VALISS"	)[1]	,/*lPixel*/,{|| nVlrISS			},,,"RIGHT")
	TRCell():New(oItens,"NDESACES"		,/*Tabela*/,STR0032,PesqPict("SD2","D2_TOTAL")	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nAcN3			},,,"RIGHT")
	TRCell():New(oItens,"NACN6"			,/*Tabela*/,STR0033,PesqPict("SD2","D2_TOTAL")	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nAcN6			},,,"RIGHT")



	// Totalizador por dia
	oTotDia := TRSection():New(oReport,STR0058,{"SF2","SD2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oTotDia:SetTotalInLine(.F.)
	TRCell():New(oTotDia,"CCOD"			,/*Tabela*/,STR0035,/*Picture*/						,TamSX3("D2_COD"	)[1]		,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"CDESC"		,/*Tabela*/,STR0036,/*Picture*/						,TamSX3("B1_DESC"	)[1]		,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"NACD1"		,/*Tabela*/,STR0037,PesqPict("SD2","D2_QUANT")		,TamSX3("D2_QUANT"	)[1]		,/*lPixel*/,{|| nAcD1 },,,"RIGHT"							)
	TRCell():New(oTotDia,"NPRCVEN"		,/*Tabela*/,STR0038,/*Picture*/						,TamSX3("D2_PRCVEN"	)[1]			  		,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT"	)
	TRCell():New(oTotDia,"NACD2"		,/*Tabela*/,STR0039,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL"	)[1]		,/*lPixel*/,{|| nAcD2 },,,"RIGHT"							)
	TRCell():New(oTotDia,"CLOCAL"		,/*Tabela*/,STR0040,/*Picture*/						,TamSX3("D2_LOCAL"  )[1]					,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"CCF"			,/*Tabela*/,STR0041,/*Picture*/						,TamSX3("D2_CF"  )[1]					,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"CTES"	  		,/*Tabela*/,STR0042,/*Picture*/						,TamSX3("D2_TES"  )[1]					,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"CPEDIDO"		,/*Tabela*/,STR0043,/*Picture*/						,TamSX3("D2_PEDIDO"  )[1]					,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"CITEMPV"		,/*Tabela*/,STR0044,/*Picture*/						,TamSX3("D2_ITEMPV"  )[1]					,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"NACD5"		,/*Tabela*/,STR0045,PesqPict("SD2","D2_VALIPI")		,TamSX3("D2_VALIPI"	)[1]		,/*lPixel*/,{|| nAcD5 },,,"RIGHT"				)
	TRCell():New(oTotDia,"NACD4"		,/*Tabela*/,STR0046,PesqPict("SD2","D2_VALICM")		,TamSX3("D2_VALICM"	)[1]		,/*lPixel*/,{|| nAcD4 },,,"RIGHT"				)
	TRCell():New(oTotDia,"NACD7"		,/*Tabela*/,STR0047,PesqPict("SD2","D2_VALISS")		,TamSX3("D2_VALISS"	)[1]		,/*lPixel*/,{|| nAcD7 },,,"RIGHT"				)	
	TRCell():New(oTotDia,"NACD3"		,/*Tabela*/,STR0032,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL"	)[1]		,/*lPixel*/,{|| nAcD3 },,,"RIGHT"				)	
	TRCell():New(oTotDia,"NACD6"		,/*Tabela*/,STR0033,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL"	)[1]		,/*lPixel*/,{|| nAcD6 },,,"RIGHT"				)


	// Totalizador das Despesas Acessorias (IPI, ICMS e Outros Gastos)
	oTotDesp := TRSection():New(oReport,STR0059,{"SF2","SD2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oTotDesp:SetTotalInLine(.F.)
	TRCell():New(oTotDesp,"CNOTA"		,/*Tabela*/,RetTitle("D2_DOC")		,PesqPict("SD2","D2_DOC"	),TamSX3("D2_DOC"		)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)	
	TRCell():New(oTotDesp,"CSERIE"		,/*Tabela*/,RetTitle("D2_SERIE")	,PesqPict("SD2","D2_SERIE"	),TamSX3("D2_SERIE"		)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDesp,"NACN1"		,/*Tabela*/,RetTitle("D2_QUANT")	,PesqPict("SD2","D2_QUANT"	),TamSX3("D2_QUANT"		)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT"	)
	TRCell():New(oTotDesp,"NACN2"		,/*Tabela*/,RetTitle("D2_TOTAL")	,PesqPict("SD2","D2_TOTAL"	),TamSX3("D2_TOTAL"		)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT"	)
	TRCell():New(oTotDesp,"NACN5"		,/*Tabela*/,RetTitle("D2_VALIPI")	,PesqPict("SD2","D2_VALIPI"	),TamSX3("D2_VALIPI"	)[1]	,/*lPixel*/,{|| nIPIDesp },,,"RIGHT"						)
	TRCell():New(oTotDesp,"NACN4"		,/*Tabela*/,RetTitle("D2_VALICM")	,PesqPict("SD2","D2_VALICM"	),TamSX3("D2_VALICM"	)[1]	,/*lPixel*/,{|| nICMDesp },,,"RIGHT"						)
	TRCell():New(oTotDesp,"NVLRISS"		,/*Tabela*/,RetTitle("D2_VALISS")	,PesqPict("SD2","D2_VALISS"	),TamSX3("D2_VALISS"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT"	)
	TRCell():New(oTotDesp,"NDESPACES"	,/*Tabela*/,STR0032					,PesqPict("SD2","D2_TOTAL"	),TamSX3("D2_TOTAL"		)[1]	,/*lPixel*/,{|| nAcN3+nFretAut },,,"RIGHT"				)
	TRCell():New(oTotDesp,"NACN6"		,/*Tabela*/,STR0033					,PesqPict("SD2","D2_TOTAL"	),TamSX3("D2_TOTAL"		)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT"	)

	

	oReport:Section(3):SetEdit(.F.)
	oReport:Section(4):SetEdit(.F.)
	oReport:Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query    
	oReport:Section(2):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query
	oReport:Section(2):Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query

Else


	oCabecF1 := TRSection():New(oReport,STR0061,{"SF1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oCabecF1:SetTotalInLine(.F.)
	TRCell():New(oCabecF1,"CCLIENTE"	,/*Tabela*/,RetTitle("F2_CLIENTE"	),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Substr(cCliente,1,6) 	})
	TRCell():New(oCabecF1,"CLOJA"		,/*Tabela*/,RetTitle("F2_LOJA"		),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cLoja 		})
	TRCell():New(oCabecF1,"CNOME"		,/*Tabela*/,RetTitle("A1_NOME"		),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cNome 		})
 	TRCell():New(oCabecF1,"CEMISSAO"	,/*Tabela*/,RetTitle("F2_EMISSAO"	),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| dEmissao 	})
	TRCell():New(oCabecF1,"CTIPO"		,/*Tabela*/,RetTitle("F2_TIPO"		),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cTipo 		})


	oCabecF2 := TRSection():New(oReport,STR0062,{"SF2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oCabecF2:SetTotalInLine(.F.)
	TRCell():New(oCabecF2,"CCLIENTE"	,/*Tabela*/,RetTitle("F2_CLIENTE"	),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Substr(cCliente,1,6) 	})
	TRCell():New(oCabecF2,"CLOJA"		,/*Tabela*/,RetTitle("F2_LOJA"		),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cLoja 		})
	TRCell():New(oCabecF2,"CNOME"		,/*Tabela*/,RetTitle("A1_NOME"		),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cNome 		})
 	TRCell():New(oCabecF2,"CEMISSAO"	,/*Tabela*/,RetTitle("F2_EMISSAO"	),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| dEmissao 	})
	TRCell():New(oCabecF2,"CTIPO"		,/*Tabela*/,RetTitle("F2_TIPO"		),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cTipo 		})


    // Analitico SD1
	oItensD1 := TRSection():New(oReport,STR0063,{"SD1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oItensD1:SetTotalInLine(.F.)
	TRCell():New(oItensD1,"CCOD"		,/*Tabela*/,RetTitle("D2_COD" 		)	,/*Picture*/					,TamSX3("D2_COD"	)[1]	,/*lPixel*/,{|| cCod		})
	TRCell():New(oItensD1,"CDESC"		,/*Tabela*/,RetTitle("B1_DESC"		)	,/*Picture*/					,TamSX3("B1_DESC"	)[1]	,/*lPixel*/,{|| cDesc		})
	TRCell():New(oItensD1,"ALMOX"		,/*Tabela*/,RetTitle("D2_LOCAL"		)	,/*Picture*/					,TamSX3("D2_LOCAL"	)[1]	,/*lPixel*/,{|| cLocal		})
	TRCell():New(oItensD1,"PEDIDO"		,/*Tabela*/,RetTitle("D2_PEDIDO"	)	,/*Picture*/					,TamSX3("D2_PEDIDO"	)[1]	,/*lPixel*/,{|| cPedido		})
	TRCell():New(oItensD1,"ITEM"		,/*Tabela*/,RetTitle("D2_ITEM"		)	,/*Picture*/					,TamSX3("D2_ITEM"	)[1]	,/*lPixel*/,{|| cItemPV		})
	TRCell():New(oItensD1,"REMITO"		,/*Tabela*/,RetTitle("D2_REMITO"	)	,/*Picture*/					,TamSX3("D2_REMITO"	)[1]	,/*lPixel*/,{|| cRemito		})
	TRCell():New(oItensD1,"ITEMREM"		,/*Tabela*/,RetTitle("D2_ITEMREM"	)	,/*Picture*/					,TamSX3("D2_ITEMREM")[1]	,/*lPixel*/,{|| cItemrem	})
	TRCell():New(oItensD1,"NQUANT"		,/*Tabela*/,RetTitle("D2_QUANT"		)	,PesqPict("SD2","D2_QUANT"	)	,TamSX3("D2_QUANT"	)[1]	,/*lPixel*/,{|| nQuant		},,,"RIGHT")
	TRCell():New(oItensD1,"NPRCVEN"		,/*Tabela*/,RetTitle("D2_PRCVEN"	)	,PesqPict("SD2","D2_PRCVEN"	)	,TamSX3("D2_PRCVEN"	)[1]	,/*lPixel*/,{|| nPrcVen		},,,"RIGHT")
	TRCell():New(oItensD1,"NTOTAL"		,/*Tabela*/,STR0039						,PesqPict("SD2","D2_TOTAL"	)	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nTotal		},,,"RIGHT")
	TRCell():New(oItensD1,"NIMPINC"		,/*Tabela*/,STR0049						,PesqPict("SD2","D2_TOTAL"	)	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nImpInc 	},,,"RIGHT")
	TRCell():New(oItensD1,"NIMPNOINC"	,/*Tabela*/,STR0050						,PesqPict("SD2","D2_TOTAL"	)	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nImpnoInc 	},,,"RIGHT")
	TRCell():New(oItensD1,"NTOTCIMP"	,/*Tabela*/,RetTitle("D2_TOTAL"		)	,PesqPict("SD2","D2_TOTAL"	)	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nTotcImp 	},,,"RIGHT")


    // Analitico SD2
	oItensD2 := TRSection():New(oReport,STR0064,{"SD2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oItensD2:SetTotalInLine(.F.)
	TRCell():New(oItensD2,"CCOD"		,/*Tabela*/,RetTitle("D2_COD"		)	,/*Picture*/					,TamSX3("D2_COD"	)[1]	,/*lPixel*/,{|| cCod		})
	TRCell():New(oItensD2,"CDESC"		,/*Tabela*/,RetTitle("B1_DESC"		)	,/*Picture*/					,TamSX3("B1_DESC"	)[1]	,/*lPixel*/,{|| cDesc		})
	TRCell():New(oItensD2,"ALMOX"		,/*Tabela*/,RetTitle("D2_LOCAL"		)	,/*Picture*/					,TamSX3("D2_LOCAL"	)[1]	,/*lPixel*/,{|| cLocal		})
	TRCell():New(oItensD2,"PEDIDO"		,/*Tabela*/,RetTitle("D2_PEDIDO"	)	,/*Picture*/					,TamSX3("D2_PEDIDO"	)[1]	,/*lPixel*/,{|| cPedido		})
	TRCell():New(oItensD2,"ITEM"		,/*Tabela*/,RetTitle("D2_ITEM"		)	,/*Picture*/					,TamSX3("D2_ITEM"	)[1]	,/*lPixel*/,{|| cItemPV		})
	TRCell():New(oItensD2,"REMITO"		,/*Tabela*/,RetTitle("D2_REMITO"	)	,/*Picture*/					,TamSX3("D2_REMITO"	)[1]	,/*lPixel*/,{|| cRemito		})
	TRCell():New(oItensD2,"ITEMREM"		,/*Tabela*/,RetTitle("D2_ITEMREM"	)	,/*Picture*/					,TamSX3("D2_ITEMREM")[1]	,/*lPixel*/,{|| cItemrem	})
	TRCell():New(oItensD2,"NQUANT"		,/*Tabela*/,RetTitle("D2_QUANT"		)	,PesqPict("SD2","D2_QUANT"	)	,TamSX3("D2_QUANT"	)[1]	,/*lPixel*/,{|| nQuant		},,,"RIGHT")
	TRCell():New(oItensD2,"NPRCVEN"		,/*Tabela*/,RetTitle("D2_PRCVEN"	)	,PesqPict("SD2","D2_PRCVEN"	)	,TamSX3("D2_PRCVEN"	)[1]	,/*lPixel*/,{|| nPrcVen		},,,"RIGHT")
	If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
		TRCell():New(oItensD2,"NVALADI"	,/*Tabela*/,RetTitle("D2_VALADI"	)	,PesqPict("SD2","D2_VALADI"	)	,TamSX3("D2_VALADI"	)[1]	,/*lPixel*/,{|| nValadi		},,,"RIGHT")
	EndIf
	TRCell():New(oItensD2,"NTOTAL"		,/*Tabela*/,STR0039						,PesqPict("SD2","D2_TOTAL"	)	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nTotal		},,,"RIGHT")
	TRCell():New(oItensD2,"NIMPINC"		,/*Tabela*/,STR0049						,PesqPict("SD2","D2_TOTAL"	)	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nImpInc 	},,,"RIGHT")
	TRCell():New(oItensD2,"NIMPNOINC"	,/*Tabela*/,STR0050						,PesqPict("SD2","D2_TOTAL"	)	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nImpnoInc 	},,,"RIGHT")
	TRCell():New(oItensD2,"NTOTCIMP"	,/*Tabela*/,RetTitle("D2_TOTAL"		)	,PesqPict("SD2","D2_TOTAL"	)	,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nTotcImp 	},,,"RIGHT")
         
    // Total Geral
   	oTotGer := TRSection():New(oReport,STR0060,{"SF2","SD2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oTotGer:SetTotalInLine(.F.)
	oTotGer:SetEdit(.F.)

	TRCell():New(oTotGer,"CCOD"			,/*Tabela*/,RetTitle("D2_COD"		)	,/*Picture*/					,TamSX3("D2_COD"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotGer,"CDESC"		,/*Tabela*/,RetTitle("B1_DESC"		)	,/*Picture*/					,TamSX3("B1_DESC"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotGer,"ALMOX"		,/*Tabela*/,RetTitle("D2_LOCAL"		)	,/*Picture*/					,TamSX3("D2_LOCAL"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotGer,"PEDIDO"		,/*Tabela*/,RetTitle("D2_PEDIDO"	)	,/*Picture*/					,TamSX3("D2_PEDIDO"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotGer,"ITEM"			,/*Tabela*/,RetTitle("D2_ITEM"		)	,/*Picture*/					,TamSX3("D2_ITEM"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotGer,"REMITO"		,/*Tabela*/,RetTitle("D2_REMITO"	)	,/*Picture*/					,TamSX3("D2_REMITO"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotGer,"ITEMREM"		,/*Tabela*/,RetTitle("D2_ITEMREM"	)	,/*Picture*/					,TamSX3("D2_ITEMREM")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotGer,"NACG1"		,/*Tabela*/,RetTitle("D2_QUANT"	)	,PesqPict("SD2","D2_QUANT"	)		,TamSX3("D2_QUANT"	)[1]	,/*lPixel*/,{|| nACG1},,,"RIGHT"				)
	TRCell():New(oTotGer,"NPRCVEN"		,/*Tabela*/,RetTitle("D2_PRCVEN")	,PesqPict("SD2","D2_PRCVEN"	)		,TamSX3("D2_PRCVEN"	)[1]	,/*lPixel*/,/*{|| code-block de impressao}*/	)
	If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
		TRCell():New(oTotGer,"NACGADI"	,/*Tabela*/,RetTitle("D2_VALADI")	,PesqPict("SD2","D2_VALADI"	)		,TamSX3("D2_VALADI"	)[1]	,/*lPixel*/,{|| nAcGAdi}	)
	EndIf	
	TRCell():New(oTotGer,"NACG2"		,/*Tabela*/,STR0039					,PesqPict("SD2","D2_TOTAL"	)		,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nACG2},,,"RIGHT"				)
	TRCell():New(oTotGer,"NACGIMPINC"	,/*Tabela*/,STR0049					,PesqPict("SD2","D2_TOTAL"	)		,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotGer,"NACGIMPNOINC"	,/*Tabela*/,STR0050					,PesqPict("SD2","D2_TOTAL"	)		,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotGer,"NTOTNETGER"	,/*Tabela*/,STR0054					,PesqPict("SD2","D2_TOTAL"	)		,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nTotNetGer},,,"RIGHT"			)	


    // Total por dia
   	oTotDia := TRSection():New(oReport,STR0034,{"SF2","SD2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oTotDia:SetTotalInLine(.F.)
	oTotDia:SetEdit(.F.)

	TRCell():New(oTotDia,"CCOD"			,/*Tabela*/,RetTitle("D2_COD"		)	,/*Picture*/					,TamSX3("D2_COD"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"CDESC"		,/*Tabela*/,RetTitle("B1_DESC"		)	,/*Picture*/					,TamSX3("B1_DESC"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"ALMOX"		,/*Tabela*/,RetTitle("D2_LOCAL"		)	,/*Picture*/					,TamSX3("D2_LOCAL"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"PEDIDO"		,/*Tabela*/,RetTitle("D2_PEDIDO"	)	,/*Picture*/					,TamSX3("D2_PEDIDO"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"ITEM"			,/*Tabela*/,RetTitle("D2_ITEM"		)	,/*Picture*/					,TamSX3("D2_ITEM"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"REMITO"		,/*Tabela*/,RetTitle("D2_REMITO"	)	,/*Picture*/					,TamSX3("D2_REMITO"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"ITEMREM"		,/*Tabela*/,RetTitle("D2_ITEMREM"	)	,/*Picture*/					,TamSX3("D2_ITEMREM")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"NACD1"		,/*Tabela*/,RetTitle("D2_QUANT"	)	,PesqPict("SD2","D2_QUANT"	)		,TamSX3("D2_QUANT"	)[1]	,/*lPixel*/,{|| nACD1},,,"RIGHT"				)
	TRCell():New(oTotDia,"NPRCVEN"		,/*Tabela*/,RetTitle("D2_PRCVEN")	,PesqPict("SD2","D2_PRCVEN"	)		,TamSX3("D2_PRCVEN"	)[1]	,/*lPixel*/,/*{|| code-block de impressao}*/	)
	If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
		TRCell():New(oTotDia,"NACDADI"	,/*Tabela*/,RetTitle("D2_VALADI")	,PesqPict("SD2","D2_VALADI"	)		,TamSX3("D2_VALADI"	)[1]	,/*lPixel*/,{|| nAcDAdi})	
	EndIf
	TRCell():New(oTotDia,"NACD2"		,/*Tabela*/,STR0039					,PesqPict("SD2","D2_TOTAL"	)		,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nACD2},,,"RIGHT"				)
	TRCell():New(oTotDia,"NACGIMPINC"	,/*Tabela*/,STR0049					,PesqPict("SD2","D2_TOTAL"	)		,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"NACGIMPNOINC"	,/*Tabela*/,STR0050					,PesqPict("SD2","D2_TOTAL"	)		,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,/*{|| code-block de impressao }*/	)
	TRCell():New(oTotDia,"NTOTDIA"		,/*Tabela*/,STR0054					,PesqPict("SD2","D2_TOTAL"	)		,TamSX3("D2_TOTAL"	)[1]	,/*lPixel*/,{|| nTotDia},,,"RIGHT"				)	

EndIf

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Marco Bianchi          � Data �05/06/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAliasQry,oSintetico,oItens,oItensD1,oItensD2,oCabec,oCabecF1,oCabecF2,oTotDia)

If ( cPaisLoc#"BRA" )

	TRFunction():New(oItensD1:Cell("NQUANT")	,/* cID */,"SUM",/*oBreak*/,STR0037,PesqPict("SD2","D2_QUANT"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oItensD1:Cell("NTOTAL")	,/* cID */,"SUM",/*oBreak*/,STR0039,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oItensD1:Cell("NIMPINC")	,/* cID */,"SUM",/*oBreak*/,STR0045,PesqPict("SD2","D2_VALIPI"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oItensD1:Cell("NIMPNOINC")	,/* cID */,"SUM",/*oBreak*/,STR0046,PesqPict("SD2","D2_VALICM"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oItensD1:Cell("NTOTCIMP")	,/* cID */,"SUM",/*oBreak*/,STR0047,PesqPict("SD2","D2_VALISS"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  

	TRFunction():New(oItensD2:Cell("NQUANT")	,/* cID */,"SUM",/*oBreak*/,STR0037,PesqPict("SD2","D2_QUANT"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
	If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0 
		TRFunction():New(oItensD2:Cell("NVALADI")	,/* cID */,"SUM",/*oBreak*/,RetTitle("D2_VALADI"),PesqPict("SD2","D2_VALADI"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	EndIf
	TRFunction():New(oItensD2:Cell("NTOTAL")	,/* cID */,"SUM",/*oBreak*/,STR0039,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oItensD2:Cell("NIMPINC")	,/* cID */,"SUM",/*oBreak*/,STR0045,PesqPict("SD2","D2_VALIPI"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oItensD2:Cell("NIMPNOINC")	,/* cID */,"SUM",/*oBreak*/,STR0046,PesqPict("SD2","D2_VALICM"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oItensD2:Cell("NTOTCIMP")	,/* cID */,"SUM",/*oBreak*/,STR0047,PesqPict("SD2","D2_VALISS"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  


	oReport:SetTotalInLine(.F.)

	#IFNDEF TOP
		TRImpLocCB(oReport)
	#ELSE
		TRImpLocTop(oReport,cAliasQry)
	#ENDIF
Else
	If mv_par17 == 2
		TRFunction():New(oSintetico:Cell("NACN1")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)  
		TRFunction():New(oSintetico:Cell("NACN2")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,{||IIF(SF2->F2_TIPO $ "IP",0,nAcN2)},.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)  
		TRFunction():New(oSintetico:Cell("NACN5")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)  
		TRFunction():New(oSintetico:Cell("NACN4")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)  
		TRFunction():New(oSintetico:Cell("NVLRISS")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)  
		TRFunction():New(oSintetico:Cell("NDESPACES")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)  
		TRFunction():New(oSintetico:Cell("NACN6")		,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,{||IIF(SF2->F2_TIPO $ "IP",0,nAcN6)},.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)   
	    
		oReport:SetTotalInLine(.F.)
		TRImpSint(oReport) 
	Else
		TRFunction():New(oTotDia:Cell("NACD1")		,/* cID */,"SUM",/*oBreak*/,STR0037,PesqPict("SD2","D2_QUANT"	),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oTotDia:Cell("NACD2")		,/* cID */,"SUM",/*oBreak*/,STR0039,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oTotDia:Cell("NACD5")		,/* cID */,"SUM",/*oBreak*/,STR0045,PesqPict("SD2","D2_VALIPI"	),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oTotDia:Cell("NACD4")		,/* cID */,"SUM",/*oBreak*/,STR0046,PesqPict("SD2","D2_VALICM"	),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oTotDia:Cell("NACD7") 		,/* cID */,"SUM",/*oBreak*/,STR0047,PesqPict("SD2","D2_VALISS"	),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oTotDia:Cell("NACD3") 		,/* cID */,"SUM",/*oBreak*/,STR0032,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oTotDia:Cell("NACD6")		,/* cID */,"SUM",/*oBreak*/,STR0033,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)  
		
		TRFunction():New(oItens:Cell("NQUANT")		,/* cID */,"SUM",/*oBreak*/,STR0037,PesqPict("SD2","D2_QUANT"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oItens:Cell("NTOTAL")		,/* cID */,"SUM",/*oBreak*/,STR0039,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oItens:Cell("NVALIPI")		,/* cID */,"SUM",/*oBreak*/,STR0045,PesqPict("SD2","D2_VALIPI"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oItens:Cell("NVALICM")		,/* cID */,"SUM",/*oBreak*/,STR0046,PesqPict("SD2","D2_VALICM"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oItens:Cell("NVALISS")		,/* cID */,"SUM",/*oBreak*/,STR0047,PesqPict("SD2","D2_VALISS"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oItens:Cell("NDESACES")	,/* cID */,"SUM",/*oBreak*/,STR0032,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
		TRFunction():New(oItens:Cell("NACN6")		,/* cID */,"SUM",/*oBreak*/,STR0033,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	 	
		oReport:SetTotalInLine(.F.)
		TRImpAna(oReport,cAliasQry,oItens,oCabec,oTotDia)   
	EndIf   
EndIf   

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TRImpSint� Autor � Marco Bianchi         � Data � 07/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Relatorio Sintetico (Base Brasil).                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550 - R4 	                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function TRImpSint(oReport)

Local nAcD1  	:= 0, nAcD2	:= 0, nAcD3	:= 0, nAcD4 := 0, nAcD5 := 0, nAcD6:= 0, nAcD7 := 0
Local lContinua	:= .T., dEmisAnt
Local nReg     	:= 0
Local nTotQuant	:= 0
Local nTotal   	:= 0
Local nTotIcm  	:= 0
Local nTotIPI  	:= 0
Local nTotRet   := 0
Local cNumPed  	:= ""
Local cMascara 	:= GetMv("MV_MASCGRD")
Local nTamRef  	:= Val(Substr(cMascara,1,2))
Local dEmiDia 	:= dDataBase
Local nFrete  	:= 0
Local nIcmAuto	:= 0
Local nSeguro 	:= 0
Local nDespesa	:= 0
Local nValIPI 	:= 0
Local nValICM 	:= 0
Local nValISS 	:= 0
Local nVlrISS   := 0
Local cTipoNF 	:= 0 
Local lFretAut	:= GetNewPar("MV_FRETAUT",.T.)
Local cKey    	:= ""
Local lQuery	:= .F.
Local cExpr 	:= ""
Local cExprGrade:= ""
Local lCompIPI	:= .F.
#IFNDEF TOP
	Local cCondicao := ""
#ENDIF

oReport:Section(1):Cell("CNOTA"		):SetBlock({|| cNota			})
oReport:Section(1):Cell("CSERIE"	):SetBlock({|| cSerie			})
oReport:Section(1):Cell("NACN1"		):SetBlock({|| nAcN1			})
oReport:Section(1):Cell("NACN2"		):SetBlock({|| nAcN2			})
oReport:Section(1):Cell("NACN5"		):SetBlock({|| nAcN5			})
oReport:Section(1):Cell("NACN4"		):SetBlock({|| nAcN4			})
oReport:Section(1):Cell("NVLRISS"	):SetBlock({|| nVlrISS 			})
oReport:Section(1):Cell("NDESPACES"	):SetBlock({|| nAcN3+nFretAut	})
oReport:Section(1):Cell("NACN6"		):SetBlock({|| nAcN6			})


//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
#IFDEF TOP
	
    If TcSrvType()<>"AS/400"
		//������������������������������������������������������������������������Ŀ
		//�Query do relat�rio da secao 1 - SINTETICO                               �
		//��������������������������������������������������������������������������
		lQuery := .T.
		cAliasQry := GetNextAlias()
		cAliasSD2 := cAliasQry
		cWhere :="%"
		If MV_PAR15 == 2
			cWhere += "AND F2_TIPO<>'D'"
		EndIf
		cWhere += " AND NOT ("+IsRemito(2,"F2_TIPODOC")+")"
		cWhere += "%"

		//������������������������������������������������������������������������Ŀ
		//�Transforma parametros Range em expressao SQL                            �
		//��������������������������������������������������������������������������
		MakeSqlExpr(oReport:uParam)
		                                       
		oReport:Section(1):BeginQuery()	
		BeginSql Alias cAliasQry
		SELECT F2_FILIAL, F2_DOC,F2_SERIE,F2_EMISSAO,F2_TIPO,F2_ICMSRET
			,F2_FRETE,F2_FRETAUT,F2_ICMAUTO,F2_VALBRUT,F2_VALIPI,F2_VALICM,F2_VALISS
			,D2_DOC,D2_SERIE,D2_COD,D2_GRUPO,D2_TP,D2_TIPO,D2_CLIENTE,D2_LOJA,D2_GRADE
			,D2_CF,D2_TES,D2_LOCAL,D2_PRCVEN,D2_ICMSRET,D2_QUANT,D2_TOTAL,D2_EMISSAO
			,D2_VALIPI,D2_CODISS,D2_VALISS,D2_VALICM,F2_FRETE,F2_SEGURO,F2_DESPESA, D2_GRADE,D2_PEDIDO, D2_ITEMPV
		FROM %Table:SF2% SF2, %Table:SD2% SD2
//		WHERE F2_FILIAL = %xFilial:SF2%
//			AND F2_DOC >= %Exp:mv_par01% AND F2_DOC <= %Exp:mv_par02%
		WHERE F2_DOC >= %Exp:mv_par01% AND F2_DOC <= %Exp:mv_par02%
			AND F2_EMISSAO >= %Exp:DtoS(mv_par03)% AND F2_EMISSAO <= %Exp:DtoS(mv_par04)%
			AND F2_SERIE >= %Exp:mv_par06% AND F2_SERIE <= %Exp:mv_par07%
			AND SF2.%notdel%
			AND D2_FILIAL = F2_FILIAL  //AND D2_FILIAL = %xFilial:SD2% 
			AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA
			AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE
			AND SD2.%notdel%       
			%Exp:cWhere%	
		ORDER BY SF2.F2_FILIAL, SF2.F2_EMISSAO,SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_COD,SD2.D2_ITEM
		EndSql       
		oReport:Section(1):EndQuery({MV_PAR16,MV_PAR10,MV_PAR05,MV_PAR11})
	Else
#ENDIF

		//��������������������������������������������������������������Ŀ
		//� Cria Indice de Trabalho                                      �
		//����������������������������������������������������������������
		cAliasQry := "SF2"
		cAliasSD2 := "SD2"  
	   
		//����������������������������������������������������������������������������������������������������Ŀ
		//�Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros para ambiente CDX �
		//������������������������������������������������������������������������������������������������������
		MakeAdvplExpr("MTR550P9R1") 		
	   
		dbSelectArea(cAliasQry)
		cKey := 'F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE'
//		cCondicao := 'F2_FILIAL=="'+xFilial("SF2")+'".And.F2_DOC>="'+mv_par01+'"'
		cCondicao := 'F2_DOC>="'+mv_par01+'"'
		cCondicao += '.And.F2_DOC<="'+mv_par02+'".And.DTOS(F2_EMISSAO)>="'+DTOS(mv_par03)+'"'
		cCondicao += '.And.DTOS(F2_EMISSAO)<="'+DTOS(mv_par04)+'".And. F2_SERIE>="'+mv_par06+'".And.F2_SERIE<= "'+mv_par07+'"'
		
		
		If !Empty(mv_par16)
			cCondicao += '.And.'+mv_par16+''
		EndIf	
		
		cCondicao += '.And. !('+IsRemito(2,'SF2->F2_TIPODOC')+')'		
		If mv_par15 == 2
			cCondicao += '.And.F2_TIPO<>"D"'
		EndIf
		
		oReport:Section(1):SetFilter(cCondicao,cKey)
#IFDEF TOP
	Endif    
#ENDIF

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
oReport:SetMeter((cAliasQry)->(LastRec()))
dbSelectArea(cAliasQry)
oReport:Section(1):Init()
lFecha := .T.
nAcN1  := 0; nAcN2	:= 0; nAcN3	:= 0; nAcN4 := 0; nAcN5 := 0; nAcN6 := 0
If !lQuery
	cExpr := IIf(!Empty(mv_par05),mv_par05,"")
	cExpr += IIf(!Empty(cExpr),IIf(!Empty(mv_par10)," .AND. "+mv_par10,""),IIf(!Empty(mv_par10),mv_par10,""))
	cExprGrade := cExpr
	cExpr += IIf(!Empty(cExpr),IIf(!Empty(mv_par11)," .AND. "+mv_par11,""),IIf(!Empty(mv_par11),mv_par11,""))
EndIf	

While !oReport:Cancel() .And. !(cAliasQry)->(Eof())

	If !lQuery
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE)
	Endif

	nTotRet  := 0
	dEmisAnt :=	(cAliasQry)->F2_EMISSAO
	cDocFil	 := (cAliasQry)->F2_FILIAL
	cNota	 := (cAliasQry)->F2_DOC
	cSerie	 := (cAliasQry)->F2_SERIE
	nFrete	 := (cAliasQry)->F2_FRETE
	nFretAut := (cAliasQry)->F2_FRETAUT	
	nIcmAuto := (cAliasQry)->F2_ICMAUTO
	nSeguro	 := (cAliasQry)->F2_SEGURO
	nDespesa := (cAliasQry)->F2_DESPESA
	nValIPI	 := (cAliasQry)->F2_VALIPI
	nValICM	 := (cAliasQry)->F2_VALICM
	nValISS	 := (cAliasQry)->F2_VALISS
	cTipoNF	 := (cAliasQry)->F2_TIPO
	
	While !Eof() .and. D2_DOC+D2_SERIE == cNota+cSerie

		If !lQuery
			If !Empty(cExpr)
				If !(&(cExpr)) .Or. D2_SERIE < mv_par06 .Or. D2_SERIE > mv_par07
					dbSkip()
					Loop
				Endif
			Else
				If D2_SERIE < mv_par06 .Or. D2_SERIE > mv_par07
					dbSkip()
					Loop
				Endif
			Endif
		Endif
		
		//�������������������������������������������Ŀ
		//� Valida o produto conforme a mascara       �
		//���������������������������������������������
		lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR08)
		If !lRet
			dbSkip()
			Loop
		Endif

		cNumPed  := D2_PEDIDO
		nTotQuant:= 0
		nTotal   := 0
		nTotICM  := 0
		nTotIPI  := 0

		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + (cAliasSD2)->D2_TES)
		If SF4->F4_INCSOL == "S"
			nTotRet += (cAliasSD2)->D2_ICMSRET
		Endif	

		nReg := 0
		dbSelectArea(cAliasQry)
		
		If (cAliasSD2)->D2_GRADE == "S" .And. MV_PAR09 == 1
			cProdRef:= Substr((cAliasSD2)->D2_COD,1,nTamRef)
			While !Eof() .And. cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef) ;
					.And. (cAliasSD2)->D2_GRADE == "S" .And. cNumPed == (cAliasSD2)->D2_PEDIDO
				nTotQuant+= (cAliasSD2)->D2_QUANT
				nTotal   += (cAliasSD2)->D2_TOTAL
				nTotIPI  += (cAliasSD2)->D2_VALIPI

				If Empty((cAliasSD2)->D2_CODISS) .And. (cAliasSD2)->D2_VALISS == 0 // ISS
					nTotIcm  += (cAliasSD2)->D2_VALICM
				EndIf
				nReg     := Recno()
				dbSkip()
				
				If !lQuery .And. !Empty(cExprGrade)
					If !(&(cExprGrade))
						dbSkip()
						Loop
					Endif
				Endif
				//�������������������������������������������Ŀ
				//� Valida o produto conforme a mascara       �
				//���������������������������������������������
				lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR08)
				If !lRet
					dbSkip()
					Loop
				Endif
				
			End
			
			If !lQuery
				If nReg > 0
					dbGoto(nReg)
					nReg:=0
				Endif
			Endif
    		nAcN1 += nTotQuant

			If SF4->F4_AGREG <> "N"   
			   nAcN2 += xMoeda(nTotal	,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			   If SF4->F4_AGREG == "D"
				   nAcN2 -= xMoeda(nTotICM,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			   EndIf
            EndIf

			nAcN4 += xMoeda(nTotICM,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			nAcN5 += xMoeda(nTotIPI,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			
		Else

			nAcN1 += (cAliasSD2)->D2_QUANT
			If SF4->F4_AGREG <> "N"   
   			   nAcN2 += xMoeda((cAliasSD2)->D2_TOTAL,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
				If SF4->F4_AGREG = "D"
					nAcN2 -= xMoeda((cAliasSD2)->D2_VALICM,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
				EndIf
			Endif

			If Empty((cAliasSD2)->D2_CODISS) .And. (cAliasSD2)->D2_VALISS == 0 // ISS
				nAcN4 += xMoeda((cAliasSD2)->D2_VALICM,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			EndIf

			nAcN5 += xMoeda((cAliasSD2)->D2_VALIPI,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			
			If (cAliasSD2)->D2_TIPO == "P"
				lCompIPI := .T.
			EndIf
			
		Endif
		dEmiDia := (cAliasSD2)->D2_EMISSAO
		
		dbSelectArea(cAliasSD2)
		If nReg==0
			dbSkip()
		Endif

    EndDo
    
	nAcN3 := 0
	If (nAcN2+nAcN4+nAcN5) # 0
		nAcN3 := xMoeda(nFrete+nSeguro+nDespesa,1,MV_PAR13,dEmiDia)
		If nAcN3 != 0 .Or. nFretAut != 0
			nAcN5 := xMoeda(nValIPI,1,MV_PAR13,dEmiDia)
			nAcN4 := xMoeda(nValICM,1,MV_PAR13,dEmiDia)
		EndIf
		If !lCompIPI
			nAcN6 := nAcN2 + nAcN3 + nAcN5 + xMoeda(nTotRet,1,MV_PAR13,dEmiDia) +If(lFretAut,nIcmAuto,0)
		Else
			nAcN6 := nAcN5
		EndIf
		
		nVlrISS:= xMoeda(nValISS,1,MV_PAR13,dEmiDia)
		
		dbSelectArea("SF2")
		dbSetOrder(1)
		dbSeek(cDocFil+cNota+cSerie)
		
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE)

		oReport:Section(1):PrintLine()		
		
	EndIf

	nAcD1 += nAcN1
	nAcD2 += nAcN2
	nAcD3 += nAcN3+nFretAut
	nAcD4 += nAcN4
	nAcD5 += nAcN5
	nAcD6 += nAcN6
	nAcD7 += nVlrISS

	nAcn1		:= 0
	nAcn2		:= 0
	nAcn3		:= 0
	nAcn4		:= 0
	nAcn5		:= 0
	nAcn6		:= 0
    nVlrISS		:= 0

	dbSelectArea(cAliasQry)
	If !lQuery
		dbSkip()
	Endif

	If nAcd1+nAcD4+nAcD5 > 0 .And. ( dEmisAnt != (cAliasQry)->F2_EMISSAO .Or. Eof() )
		oReport:Section(1):SetTotalText(STR0034 +  DtoC(dEmisAnt))
		oReport:Section(1):Finish()
		oReport:SkipLine(2)		
		oReport:Section(1):Init()
		nAcD1 	:= 0
		nAcD2 	:= 0
		nAcD3 	:= 0
		nAcD4 	:= 0
		nAcD5 	:= 0
		nAcD6 	:= 0
		nAcD7 	:= 0
		lFecha 	:= .F.
	EndIf	

	oReport:IncMeter()
EndDo

If lFecha
	oReport:Section(1):Finish()
EndIf

oReport:Section(1):SetPageBreak(.T.) 

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TRImpAna � Autor � Marco Bianchi         � Data � 07/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Relatorio Analitico (Base Brasil).                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550 - R4		                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function TRImpAna(oReport,cAliasQry,oItens,oCabec,oTotDia)
        
Local nAcD1  	:= 0, nAcD2 := 0, nAcD3 := 0, nAcD4 := 0, nAcD5 := 0, nAcD6:= 0, nAcD7 := 0
Local lContinua	:= .T., dEmisAnt
Local nReg     	:= 0
Local nTotQuant	:= 0
Local nTotal   	:= 0
Local nTotIcm  	:= 0
Local nTotIPI  	:= 0
Local nTotRet   := 0
Local nTotRetIt := 0
Local cNumPed  	:= ""
Local cMascara 	:= GetMv("MV_MASCGRD")
Local nTamRef  	:= Val(Substr(cMascara,1,2))
Local dEmiDia 	:= dDataBase
Local nFrete  	:= 0
Local nIcmAuto	:= 0
Local nSeguro 	:= 0
Local nDespesa	:= 0
Local nValIPI 	:= 0
Local nValICM 	:= 0
Local nValISS 	:= 0
Local nVlrISS   := 0
Local cTipoNF 	:= 0 
Local lFretAut	:= GetNewPar("MV_FRETAUT",.T.)
Local cKey    	:= ""               
Local lQuery	:= .F.
Local cExpr     := ""
Local cExprGrade:= "" 
Local lFirst	:= .F.

#IFNDEF TOP
	Local cCondicao := ""
#ENDIF

oReport:Section(2):Cell("F2_CLIENTE"	):SetBlock({|| cCliente	})
oReport:Section(2):Cell("F2_LOJA"		):SetBlock({|| cLoja	})
oReport:Section(2):Cell("A1_NOME"		):SetBlock({|| cNome	})
oReport:Section(2):Cell("F2_EMISSAO"	):SetBlock({|| dEmissao	})
oReport:Section(2):Cell("F2_TIPO"		):SetBlock({|| cTipo	})

oReport:Section(2):Section(1):Cell("CCOD"		):SetBlock({|| cCod				})
oReport:Section(2):Section(1):Cell("CDESC"		):SetBlock({|| cDesc			})
oReport:Section(2):Section(1):Cell("NQUANT"	):SetBlock({|| nQuant			})
oReport:Section(2):Section(1):Cell("NPRCVEN"	):SetBlock({|| nPrcVen			})
#IFNDEF TOP
	oReport:Section(2):Section(1):Cell("NTOTAL"	):SetBlock({||xMoeda((cAliasSD2)->D2_TOTAL,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO, TAMSX3("D2_TOTAL")[2] ) })
#ELSE
	oReport:Section(2):Section(1):Cell("NTOTAL"	):SetBlock({|| xMoeda((cAliasQry)->D2_TOTAL,1,MV_PAR13,(cAliasQry)->D2_EMISSAO, TAMSX3("D2_TOTAL")[2]) })
#ENDIF 
oReport:Section(2):Section(1):Cell("CLOCAL"	):SetBlock({|| cLocal			})
oReport:Section(2):Section(1):Cell("CCF"		):SetBlock({|| cCF				})
oReport:Section(2):Section(1):Cell("CTES"		):SetBlock({|| cTes				})
oReport:Section(2):Section(1):Cell("CPEDIDO"	):SetBlock({|| cPedido			})
oReport:Section(2):Section(1):Cell("CITEMPV"	):SetBlock({|| cItemPV			})
oReport:Section(2):Section(1):Cell("NVALIPI"	):SetBlock({|| nValIPI			})
oReport:Section(2):Section(1):Cell("NVALICM"	):SetBlock({|| nValIcm			})
oReport:Section(2):Section(1):Cell("NVALISS"	):SetBlock({|| nVlrISS			})
oReport:Section(2):Section(1):Cell("NDESACES"	):SetBlock({|| nAcN3			})
#IFNDEF TOP
	oReport:Section(2):Section(1):Cell("NACN6"		):SetBlock({||IIF((cAliasSD2)->D2_TIPO $ "P",xMoeda((cAliasSD2)->D2_VALIPI,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO),xMoeda((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_VALIPI+nTotRetIt,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO, TAMSX3("D2_TOTAL")[2]))})	
#ELSE
	oReport:Section(2):Section(1):Cell("NACN6"		):SetBlock({||IIF((cAliasQry)->D2_TIPO $ "P",xMoeda((cAliasQry)->D2_VALIPI,1,MV_PAR13,(cAliasQry)->D2_EMISSAO),xMoeda((cAliasQry)->D2_TOTAL+(cAliasQry)->D2_VALIPI+nTotRetIt,1,MV_PAR13,(cAliasQry)->D2_EMISSAO, TAMSX3("D2_TOTAL")[2]))})
#ENDIF
        
oReport:Section(3):Cell("CCOD"		)
oReport:Section(3):Cell("CDESC"		)
oReport:Section(3):Cell("NACD1"		):SetBlock({|| nAcD1			})
oReport:Section(3):Cell("NPRCVEN"	)
oReport:Section(3):Cell("NACD2"		):SetBlock({|| nAcD2 			})
oReport:Section(3):Cell("CLOCAL"	)
oReport:Section(3):Cell("CCF"		)
oReport:Section(3):Cell("CTES"		)
oReport:Section(3):Cell("CPEDIDO"	)
oReport:Section(3):Cell("CITEMPV"	)
oReport:Section(3):Cell("NACD5"		):SetBlock({|| nAcD5			})
oReport:Section(3):Cell("NACD4"		):SetBlock({|| nAcD4			})
oReport:Section(3):Cell("NACD7"		):SetBlock({|| nAcD7			})
oReport:Section(3):Cell("NACD3"		):SetBlock({|| nAcD3			})
oReport:Section(3):Cell("NACD6"		):SetBlock({|| nAcD6 			})
            

//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
#IFDEF TOP
    If TcSrvType()<>"AS/400"		
		//������������������������������������������������������������������������Ŀ
		//�Query do relat�rio da secao 1 - SINTETICO                               �
		//��������������������������������������������������������������������������
		lQuery	:= .T.
		cAliasSD2 := cAliasQry
		cWhere :="%"
		If MV_PAR15 == 2
			cWhere += "AND F2_TIPO<>'D'"
		EndIf
		cWhere += " AND NOT ("+IsRemito(2,"F2_TIPODOC")+")"
		cWhere +="%"

		//������������������������������������������������������������������������Ŀ
		//�Transforma parametros Range em expressao SQL                            �
		//��������������������������������������������������������������������������
		MakeSqlExpr(oReport:uParam)
		
		oReport:Section(2):BeginQuery()	
		BeginSql Alias cAliasQry
		SELECT F2_FILIAL, F2_DOC,F2_SERIE,F2_EMISSAO,F2_TIPO,F2_ICMSRET,F2_CLIENTE,F2_LOJA
			,F2_FRETE,F2_FRETAUT,F2_ICMAUTO,F2_VALBRUT,F2_VALIPI,F2_VALICM,F2_VALISS
			,D2_DOC,D2_SERIE,D2_COD,D2_GRUPO,D2_TP,D2_TIPO,D2_CLIENTE,D2_LOJA,D2_GRADE
			,D2_CF,D2_TES,D2_LOCAL,D2_PRCVEN,D2_ICMSRET,D2_QUANT,D2_TOTAL,D2_EMISSAO
			,D2_VALIPI,D2_CODISS,D2_VALISS,D2_VALICM,D2_ITEM,F2_FRETE,F2_SEGURO,F2_DESPESA, D2_GRADE,D2_PEDIDO, D2_ITEMPV
			,B1_DESC, A1_NOME, A1_COD, A1_LOJA
		FROM %Table:SD2% SD2, %Table:SB1% SB1, %Table:SF2% SF2

		LEFT JOIN %Table:SA1% SA1
			ON	A1_FILIAL	= %xFilial:SA1% 
			AND A1_COD		= F2_CLIENTE
			AND	A1_LOJA		= F2_LOJA  
			AND SA1.%notdel%

//		WHERE F2_FILIAL = %xFilial:SF2%
//			AND F2_DOC >= %Exp:mv_par01% AND F2_DOC <= %Exp:mv_par02%
		WHERE F2_DOC >= %Exp:mv_par01% AND F2_DOC <= %Exp:mv_par02%
			AND F2_EMISSAO >= %Exp:DtoS(mv_par03)% AND F2_EMISSAO <= %Exp:DtoS(mv_par04)%
			AND F2_SERIE >= %Exp:mv_par06% AND F2_SERIE <= %Exp:mv_par07%
			AND SF2.%notdel%
			AND D2_FILIAL = F2_FILIAL
			AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA
			AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE
			AND SD2.%notdel%       
			AND B1_FILIAL = %xFilial:SB1%
			AND B1_COD = D2_COD
			AND SB1.%notdel%       
			%Exp:cWhere%	
		ORDER BY SF2.F2_FILIAL, SF2.F2_EMISSAO,SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_COD,SD2.D2_ITEM
		EndSql       
		oReport:Section(2):EndQuery({mv_par16,mv_par05,mv_par10,mv_par11})
	Else
#ENDIF

		//����������������������������������������������������������������������������������������������������Ŀ
		//�Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros para ambiente CDX �
		//������������������������������������������������������������������������������������������������������	
		MakeAdvplExpr("MTR550P9R1") 

		//��������������������������������������������������������������Ŀ
		//� Cria Indice de Trabalho                                      �
		//����������������������������������������������������������������
		cAliasQry := "SF2"
		cAliasSD2 := "SD2"
		dbSelectArea(cAliasQry)
		cKey := 'F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE'
//		cCondicao := 'F2_FILIAL=="'+xFilial("SF2")+'".And.F2_DOC>="'+mv_par01+'"'
//		cCondicao += '.And.F2_DOC<="'+mv_par02+'".And.DTOS(F2_EMISSAO)>="'+DTOS(mv_par03)+'"'
//		cCondicao += '.And.DTOS(F2_EMISSAO)<="'+DTOS(mv_par04)+'".And. F2_SERIE>="'+mv_par06+'".And.F2_SERIE<= "'+mv_par07+'"'
		cCondicao := 'F2_DOC>="'+mv_par01+'"'
		cCondicao += '.And.F2_DOC<="'+mv_par02+'".And.DTOS(F2_EMISSAO)>="'+DTOS(mv_par03)+'"'
		cCondicao += '.And.DTOS(F2_EMISSAO)<="'+DTOS(mv_par04)+'".And. F2_SERIE>="'+mv_par06+'".And.F2_SERIE<= "'+mv_par07+'"'
	

		If !Empty(mv_par16)
			cCondicao += '.And.'+mv_par16+''
		EndIf	

		cCondicao += '.And. !('+IsRemito(2,'SF2->F2_TIPODOC')+')'		
		If mv_par15 == 2
			cCondicao += '.And.F2_TIPO<>"D"'
		EndIf
		
		oReport:Section(2):SetFilter(cCondicao,cKey)
		

#IFDEF TOP
	Endif    
#ENDIF

#IFDEF TOP
	TRPosition():New(oReport:Section(2),"SA1",1,{|| xFilial("SA1") + (cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA })
	TRPosition():New(oReport:Section(2),"SD2",3,{|| (cAliasQry)->F2_FILIAL + (cAliasQry)->F2_DOC+(cAliasQry)->F2_SERIE+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEM })		
	TRPosition():New(oReport:Section(2),"SF2",1,{|| (cAliasQry)->F2_FILIAL + (cAliasQry)->F2_DOC+(cAliasQry)->F2_SERIE+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA})		
	TRPosition():New(oReport:Section(2):Section(1),"SB1",1,{|| xFilial("SB1") + (cAliasQry)->D2_COD })
	TRPosition():New(oReport:Section(2):Section(1),"SD2",3,{|| (cAliasQry)->F2_FILIAL + (cAliasQry)->F2_DOC+(cAliasQry)->F2_SERIE+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEM })		
	TRPosition():New(oReport:Section(2):Section(1),"SF2",1,{|| (cAliasQry)->F2_FILIAL + (cAliasQry)->F2_DOC+(cAliasQry)->F2_SERIE+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA})		
#ENDIF

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
oReport:SetMeter((cAliasQry)->(LastRec()))
dbSelectArea(cAliasQry)
nAcN1		:= 0; nAcN2	:= 0; nAcN3	:= 0; nAcN4	:= 0; nAcN5	:= 0; nAcN6	:= 0
If !lQuery
	cExpr := IIf(!Empty(mv_par05),mv_par05,"")
	cExpr += IIf(!Empty(cExpr),IIf(!Empty(mv_par10)," .AND. "+mv_par10,""),IIf(!Empty(mv_par10),mv_par10,""))
	cExprGrade := cExpr	
	cExpr += IIf(!Empty(cExpr),IIf(!Empty(mv_par11)," .AND. "+mv_par11,""),IIf(!Empty(mv_par11),mv_par11,""))
EndIf 

While !oReport:Cancel() .And. !(cAliasQry)->(Eof())

	IF (cAliasQry)->F2_TIPO $ "BD"
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial()+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA)		
		oCabec:Cell("F2_CLIENTE"):SetTitle("Fornecedor")           
		cNome := SA2->A2_NOME		
	else
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial()+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA)		
		oCabec:Cell("F2_CLIENTE"):SetTitle("Cliente")
		cNome := SA1->A1_NOME		
	EndIf
	
	dbSelectArea(cAliasQry)	
	If !lQuery
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek((cAliasQry)->F2_FILIAL+(cAliasQry)->F2_DOC+(cAliasQry)->F2_SERIE)
	Endif

	nTotRet		:= 0
	nTotRetIt	:= 0
	nCt			:= 1      
	dEmisAnt	:= (cAliasQry)->F2_EMISSAO
	cDocFil		:= (cAliasQry)->F2_FILIAL
	cNota		:= (cAliasQry)->F2_DOC
	cSerie		:= (cAliasQry)->F2_SERIE
	nFrete		:= (cAliasQry)->F2_FRETE
	nICMSRet	:= (cAliasQry)->F2_ICMSRET	
	nFretAut	:= (cAliasQry)->F2_FRETAUT	
	nIcmAuto	:= (cAliasQry)->F2_ICMAUTO
	nSeguro		:= (cAliasQry)->F2_SEGURO
	nDespesa	:= (cAliasQry)->F2_DESPESA
	nValIPIF2	:= (cAliasQry)->F2_VALIPI
	nValICMF2	:= (cAliasQry)->F2_VALICM
	nValISSF2	:= (cAliasQry)->F2_VALISS
	cTipoNF		:= (cAliasQry)->F2_TIPO
	dEmissao    := (cAliasQry)->F2_EMISSAO
	cTipo	    := (cAliasQry)->F2_TIPO
	cCliente	:= (cAliasQry)->F2_CLIENTE
	cLoja		:= (cAliasQry)->F2_LOJA		

	oReport:Section(2):Init()
	oReport:Section(2):Section(1):Init()
      
	lFirst := .T.  	
	
	While !Eof() .and. D2_DOC+D2_SERIE == cNota+cSerie

		If !lQuery
			If !Empty(cExpr)
				If !(&(cExpr)) .Or. D2_SERIE < mv_par06 .Or. D2_SERIE > mv_par07
					dbSkip()
					Loop
				Endif
			Else
				If D2_SERIE < mv_par06 .Or. D2_SERIE > mv_par07
					dbSkip()
					Loop
				Endif
			Endif
		Endif  
		
		//�������������������������������������������Ŀ
		//� Valida o produto conforme a mascara       �
		//���������������������������������������������
		lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR08)
		If !lRet
			dbSkip()
			Loop
		Endif

		cNumPed  := D2_PEDIDO
		nTotQuant:= 0
		nTotal   := 0
		nTotICM  := 0
		nTotIPI  := 0

		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4") + (cAliasSD2)->D2_TES)
		If SF4->F4_INCSOL == "S"
			nTotRet += (cAliasSD2)->D2_ICMSRET
			nTotRetIt:= (cAliasSD2)->D2_ICMSRET
		Endif	

		nReg := 0    
		dbSelectArea(cAliasQry)
		If (cAliasSD2)->D2_GRADE == "S" .And. MV_PAR09 == 1
			cProdRef:= Substr((cAliasSD2)->D2_COD,1,nTamRef)
			While !Eof() .And. cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef) ;
					.And. (cAliasSD2)->D2_GRADE == "S" .And. cNumPed == (cAliasSD2)->D2_PEDIDO
				nTotQuant+= (cAliasSD2)->D2_QUANT
				nTotal   += (cAliasSD2)->D2_TOTAL
				nTotIPI  += (cAliasSD2)->D2_VALIPI

				If Empty((cAliasSD2)->D2_CODISS) .And. (cAliasSD2)->D2_VALISS == 0 // ISS
					nTotIcm  += (cAliasSD2)->D2_VALICM
				EndIf
				nReg     := Recno()
				dbSkip()

				If !lQuery .And. !Empty(cExprGrade)
					If !(&(cExprGrade))
						dbSkip()
						Loop
					Endif
				EndIf	
				
				//�������������������������������������������Ŀ
				//� Valida o produto conforme a mascara       �
				//���������������������������������������������
				lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR08)
				If !lRet
					dbSkip()
					Loop
				Endif
				
			End
			
			If !lQuery
				If nReg > 0
					dbGoto(nReg)
					nReg:=0
				Endif
				
				dbSelecTArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD)
			Endif
    		nAcN1 += nTotQuant
    		
			If SF4->F4_AGREG <> "N"   
			   nAcN2 += xMoeda(nTotal	,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			   If SF4->F4_AGREG == "D"
				   nAcN2 -= xMoeda(nTotICM,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			   EndIf
            EndIf

			nAcN4 += xMoeda(nTotICM,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			nAcN5 += xMoeda(nTotIPI,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)

			cCod	:= (cAliasSD2)->D2_COD
			If mv_par12 == 1
				dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
	    	    cDesc := B1_DESC
			Else
				dbSelectArea("SA7");dbSetOrder(2)
				If dbSeek(xFilial()+(cAliasSD2)->D2_COD+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA)
	        	    cDesc := A7_DESCCLI
				Else
					dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
	    	        cDesc := B1_DESC
				Endif
			Endif
			
			nQuant	:= (cAliasSD2)->D2_QUANT			
			nPrcVen	:= xMoeda((cAliasSD2)->D2_PRCVEN  ,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			cLocal	:= (cAliasSD2)->D2_LOCAL
			nAcN2	:= xMoeda((cAliasSD2)->D2_TOTAL  ,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			cCF		:= (cAliasSD2)->D2_CF
			cTes	:= (cAliasSD2)->D2_TES
			cPedido	:= (cAliasSD2)->D2_PEDIDO
			cItemPV	:= (cAliasSD2)->D2_ITEMPV
			nVlrISS	:= xMoeda(nValISS,1,MV_PAR13,dEmiDia)
			
			If lRet .And. lFirst
				oReport:Section(2):PrintLine()
				  lFirst := .F.
			Endif
			
			oReport:Section(2):Section(1):PrintLine()
			
		Else
    		
			cCod	:= (cAliasSD2)->D2_COD
			If mv_par12 == 1
				dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
	    	    cDesc := B1_DESC
			Else
				dbSelectArea("SA7");dbSetOrder(2)
				If dbSeek(xFilial()+(cAliasSD2)->D2_COD+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA)
	        	    cDesc := A7_DESCCLI
				Else
					dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
	    	        cDesc := B1_DESC
				Endif
			Endif
	
			nQuant	:= (cAliasSD2)->D2_QUANT
			nPrcVen	:= xMoeda((cAliasSD2)->D2_PRCVEN  ,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO, TAMSX3("D2_PRCVEN")[2])
			cLocal	:= (cAliasSD2)->D2_LOCAL
			nTotal	:= xMoeda((cAliasSD2)->D2_TOTAL,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO, TAMSX3("D2_TOTAL")[2])
			cCF		:= (cAliasSD2)->D2_CF
			cTes	:= (cAliasSD2)->D2_TES
			cPedido	:= (cAliasSD2)->D2_PEDIDO
			cItemPV	:= (cAliasSD2)->D2_ITEMPV
			nValIpi	:= xMoeda((cAliasSD2)->D2_VALIPI,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)	
			nValIcm	:= IIF (SF4->F4_ICM == "S",xMoeda((cAliasSD2)->D2_VALICM,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO),0)
			nVlrISS	:= IIF (SF4->F4_ISS == "S",xMoeda((cAliasSD2)->D2_VALISS,1,MV_PAR13,dEmiDia),0)			
			
			If lRet .And. lFirst
				oReport:Section(2):PrintLine()
				lFirst := .F.
			Endif
			
			oReport:Section(2):Section(1):PrintLine()
			
			nAcN1 += (cAliasSD2)->D2_QUANT

			If SF4->F4_AGREG <> "N"   
   			   nAcN2 += xMoeda((cAliasSD2)->D2_TOTAL,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO, TAMSX3("D2_TOTAL")[2])   //IIF(!((cAliasQry)->F2_TIPO $ "IP"),xMoeda((cAliasSD2)->D2_TOTAL,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO, TAMSX3("D2_TOTAL")[2]),0)
				If SF4->F4_AGREG = "D"
					nAcN2 -= xMoeda((cAliasSD2)->D2_VALICM,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
				EndIf
			Endif
		
			If Empty((cAliasSD2)->D2_CODISS) .And. (cAliasSD2)->D2_VALISS == 0 // ISS
				nAcN4 += xMoeda((cAliasSD2)->D2_VALICM,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)
			EndIf

			nAcN5 += xMoeda((cAliasSD2)->D2_VALIPI,1,MV_PAR13,(cAliasSD2)->D2_EMISSAO)

		Endif
		dEmiDia := (cAliasSD2)->D2_EMISSAO
		
		dbSelectArea(cAliasSD2)
		If nReg==0
			dbSkip()
		Endif

    EndDo

	nAcN3 := 0
	If (nAcN2+nAcN4+nAcN5) # 0

		//��������������������������������������������������������������Ŀ
		//� Se nota tem ICMS Solidario, imprime.			             �
		//����������������������������������������������������������������
		If nICMSRet > 0
			oReport:PrintText(STR0052 + " ------------> " + Str(nICMSRet,14,2))		// ICMS SOLIDARIO
		EndIf	

		//��������������������������������������������������������������Ŀ
		//� Se nota tem ICMS Ref.Frete Autonomo, imprime.                �
		//����������������������������������������������������������������
		If nICMAuto > 0
			oReport:PrintText(STR0053 + " ------------> " + Str(nICMAuto,14,2))		// ICMS REF.FRETE AUTONOMO
		EndIf

		nAcN3 := xMoeda(nFrete+nSeguro+nDespesa,1,MV_PAR13,dEmiDia)
		If nAcN3 != 0 .Or. nFretAut != 0
			nIPIDesp := xMoeda(nValIPI,1,MV_PAR13,dEmiDia) - nAcN5
			nICMDesp := xMoeda(nValICM,1,MV_PAR13,dEmiDia) - nAcN4
			nAcN5 := xMoeda(nValIPIF2,1,MV_PAR13,dEmiDia)
			nAcN4 := xMoeda(nValICMF2,1,MV_PAR13,dEmiDia)
			
			If nIPIDesp > 0
				oReport:PrintText(STR0032 + " ------------> IPI           : " + Str(nIPIDesp,14,2) )	// DESPESAS ACESSORIAS
			EndIf
			If 	nICMDesp > 0
				oReport:PrintText(STR0032 + " ------------> ICM            : " + Str(nICMDesp,14,2)  )	// DESPESAS ACESSORIAS
			EndIf
			If 	(nAcN3+nFretAut) > 0
				oReport:PrintText(STR0032 + " ------------> OUTRAS DESPESAS: " + Str(nAcN3+nFretAut,14,2)  )	// DESPESAS ACESSORIAS
			EndIf	
			
		EndIf
		
		nAcN6 := nAcN2 + nAcN3 + nAcN5 + xMoeda(nTotRet,1,MV_PAR13,dEmiDia) +If(lFretAut,nIcmAuto,0)
		nVlrISS:= xMoeda(nValISSF2,1,MV_PAR13,dEmiDia)
		
		// Total da Nota
		oReport:Section(2):Section(1):SetTotalText(STR0048 +  cNota + "/" + cSerie)
		oReport:Section(2):Section(1):Finish()    
		oReport:Section(2):Finish()
		
		
		nAcN3 += nFretAut

		If (nICMSRet > 0) .Or. (nICMAuto > 0) .Or. (nAcN3 != 0 .Or. nFretAut != 0)
		   oReport:SkipLine(1)
		EndIf
	EndIf

	nAcD1 += nAcN1
	nAcD2 += IIF(cTipoNF $ "IP",0,nAcN2)
	nAcD3 += nAcN3
	nAcD4 += nAcN4
	nAcD5 += nAcN5
	nAcD6 += IIF(cTipoNF $ "IP",0,nAcN6)
	nAcD7 += nVlrISS

	nAcn1		:= 0
	nAcn2		:= 0
	nAcn3		:= 0
	nAcn4		:= 0
	nAcn5		:= 0
	nAcn6		:= 0
    nVlrISS		:= 0
	
	dbSelectArea(cAliasQry)
	If !lQuery
		dbSkip()
	Endif

	If nAcd1+nAcD4+nAcD5 > 0 .And. ( dEmisAnt != (cAliasQry)->F2_EMISSAO .Or. Eof() )
                        
		oReport:Section(3):SetHeaderSection(.F.)
		oReport:PrintText(STR0034 +  DtoC(dEmisAnt))
		oReport:FatLine() 
		oReport:Section(3):Init()
	   	oReport:Section(3):PrintLine()	   			
		oReport:Section(3):Finish()
		oReport:SkipLine(3)		
		
		nAcD1 	:= 0
		nAcD2 	:= 0
		nAcD3 	:= 0
		nAcD4 	:= 0
		nAcD5 	:= 0
		nAcD6 	:= 0
		nAcD7 	:= 0
		
	EndIf	

	oReport:IncMeter()
EndDo

oReport:Section(2):SetPageBreak(.T.) 

Return

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TRImpLocTop� Autor � Marco Bianchi        � Data � 07/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Relatorio (Base Localizada - Top)             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550 - R4                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TRImpLocTop(oReport,cAliasQry)

Local nCt 				:= 0
Local lContinua 		:= .T., dEmisAnt
Local cExpTot			:= ""

Private aImpostos		:= {}
Private cAliasSF2 		:= ""
Private cAliasSF1 		:= ""
Private cAliasSD1 		:= ""
Private cAliasSD2 		:= ""
Private nFrete   		:= 0
Private nFretAut 		:= 0
Private nSeguro  		:= 0
Private nDespesa 		:= 0
Private	nMoeda   		:= 0
Private	nTxMoeda 		:= 0
Private nDecs			:= MsDecimais(mv_par13)


oReport:Section(1):Cell("CCLIENTE"	):SetBlock({|| Substr(cCliente,1,6)	})
oReport:Section(1):Cell("CLOJA"		):SetBlock({|| cLoja	})
oReport:Section(1):Cell("CNOME"		):SetBlock({|| cNome	})
oReport:Section(1):Cell("CEMISSAO"	):SetBlock({|| dEmissao	})
oReport:Section(1):Cell("CTIPO"		):SetBlock({|| cTipo	})

oReport:Section(2):Cell("CCLIENTE"	):SetBlock({|| Substr(cCliente,1,6)	})
oReport:Section(2):Cell("CLOJA"		):SetBlock({|| cLoja	})
oReport:Section(2):Cell("CNOME"		):SetBlock({|| cNome	})
oReport:Section(2):Cell("CEMISSAO"	):SetBlock({|| dEmissao	})
oReport:Section(2):Cell("CTIPO"		):SetBlock({|| cTipo	})


oReport:Section(5):Cell("NACG1"			):SetBlock({|| nAcG1		})
oReport:Section(5):Cell("NACG2"			):SetBlock({|| nAcG2 		})
If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
	oReport:Section(5):Cell("NACGADI"		):SetBlock({|| nAcGADI 		})
EndIf
oReport:Section(5):Cell("NACGIMPINC"	):SetBlock({|| nAcGImpInc 	})
oReport:Section(5):Cell("NACGIMPNOINC"	):SetBlock({|| nAcGImpNoInc	})
oReport:Section(5):Cell("NTOTNETGER"	):SetBlock({|| nTotNetGer	})

oReport:Section(6):Cell("NACD1"		):SetBlock({|| nAcD1		})
oReport:Section(6):Cell("NACD2"		):SetBlock({|| nAcD2 		})
If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
	oReport:Section(6):Cell("NACDADI"	):SetBlock({|| nAcDAdi 		}) 
EndIf
oReport:Section(6):Cell("NTOTDIA"	):SetBlock({|| nTotDia	})

If mv_par17 == 2
	oReport:Section(3):SetHeaderSection(.F.)	// Desabilita Impressao Cabecalho no Topo da Pagina
	oReport:Section(4):SetHeaderSection(.T.)	// Desabilita Impressao Cabecalho no Topo da Pagina
	oReport:Section(3):Disable()

	If cPaisLoc # "PAR" .AND. cPaisLoc # "MEX"
		oReport:Section(4):Hide()
	EndIf
	
	oReport:Section(4):Acell[1]:SetTitle(Space(Len(oReport:Section(4):Acell[1]:GETTEXT())))
	oReport:Section(4):Acell[2]:SetTitle(Space(Len(oReport:Section(4):Acell[2]:GETTEXT()))) 
	oReport:Section(4):Acell[3]:Disable()
	oReport:Section(4):Acell[4]:Disable()
	oReport:Section(4):Acell[5]:Disable()
	oReport:Section(4):Acell[6]:Disable()
	oReport:Section(4):Acell[7]:Disable()
	oReport:Section(4):Acell[9]:Disable() //PRCVEN
	
	oReport:Section(5):Acell[3]:Disable()
	oReport:Section(5):Acell[4]:Disable()
	oReport:Section(5):Acell[5]:Disable()
	oReport:Section(5):Acell[6]:Disable()
	oReport:Section(5):Acell[7]:Disable()
	oReport:Section(5):Acell[9]:Disable() //PRCVEN
	
	oReport:Section(6):Acell[3]:Disable()
	oReport:Section(6):Acell[4]:Disable()
	oReport:Section(6):Acell[5]:Disable()
	oReport:Section(6):Acell[6]:Disable()
	oReport:Section(6):Acell[7]:Disable()
	oReport:Section(6):Acell[9]:Disable() //PRCVEN
			
EndIf
 
cDocFil		:= ""
cNota		:= ""
cSerie		:= ""
nAcN1		:= 0
nAcN2		:= 0
nAcImpInc	:= 0
nAcImpnoInc	:= 0
nAcDImpInc  := 0
nAcDImpNoInc:= 0
nAcD1		:= 0
nAcD2		:= 0
nAcD3		:= 0
nAcDAdi		:= 0
nAcG1		:= 0
nAcG2		:= 0
nAcGADI		:= 0
nAcGImpInc	:= 0
nAcGImpNoInc:= 0
nAcG3		:= 0
nTotNeto	:= 0
nTotNetGer	:= 0
nTotDia		:= 0



//��������������������������������������������������������������Ŀ
//� Cria Indice de Trabalho                                      �
//����������������������������������������������������������������
cWhereF2 :="%"
if mv_par14==2   //nao imprimir notas com moeda diferente da escolhida
	cWhereF2 +=" AND F2_MOEDA=" + Alltrim(str(mv_par13))
endif
cWhereF2 += " AND NOT ("+IsRemito(2,"F2_TIPODOC")+")"

cWhereF1 :="%"
if mv_par14==2   //nao imprimir notas com moeda diferente da escolhida
	cWhereF1 +=" AND F1_MOEDA=" + Alltrim(str(mv_par13))
endif
cWhereF1 += " AND NOT ("+IsRemito(2,"F1_TIPODOC")+")"

cSCpo:="1"
cCpo:="D2_VALIMP"+cSCpo
cCamposD2 := "%"
While SD2->(FieldPos(cCpo))>0
	cCamposD2 += ","+cCpo + " " + Substr(cCpo,4)
	cSCpo:=Soma1(cSCpo)
	cCpo:="D2_VALIMP"+cSCpo
Enddo
cCamposD2 += "%"

cSCpo:="1"
cCpo:="D1_VALIMP"+cSCpo
cCamposD1 := "%"
While SD1->(FieldPos(cCpo))>0
	cCamposD1 += ","+cCpo + " " + Substr(cCpo,4)
	cSCpo:=Soma1(cSCpo)
	cCpo:="D1_VALIMP"+cSCpo
Enddo
cCamposD1 += "%"

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)

If !Empty(mv_par05)
	cWhereF2 += " AND " + MV_PAR05
	cWhereF1 += " AND " + StrTran(MV_PAR05, "D2_", "D1_")
EndIf	
If !Empty(mv_par10)
	cWhereF2 += " AND " + MV_PAR10
	cWhereF1 += " AND " + StrTran(MV_PAR10, "D2_", "D1_")
EndIf	
If !Empty(mv_par11)
	cWhereF2 += " AND " + MV_PAR11
	cWhereF1 += " AND " + StrTran(MV_PAR11, "D2_", "D1_")
EndIf	
If !Empty(mv_par16)
	cWhereF2 += " AND " + MV_PAR16
	cWhereF1 += " AND " + StrTran(MV_PAR16, "F2_CLIENTE", "F1_FORNECE")
EndIf	
cWhereF2 +="%"
cWhereF1 +="%"

If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
	cExpTot := "% D2_TOTAL-D2_VALADI TOTAL, D2_VALADI VALADI%"
Else 
	cExpTot := "% D2_TOTAL TOTAL,0 VALADI %"
EndIf

oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
SELECT 	F2_FILIAL FILIAL, F2_CLIENTE CLIFOR,F2_LOJA LOJA,F2_DOC DOC,F2_SERIE SERIE,F2_EMISSAO EMISSAO
		,F2_MOEDA MOEDA,F2_TXMOEDA TXMOEDA,F2_TIPO TIPO,F2_ESPECIE ESPECIE
		,F2_FRETE FRETE,F2_FRETAUT FRETAUT,F2_SEGURO SEGURO,F2_DESPESA DESPESA
		,SA1.A1_NOME NOME,D2_DOC DOCITEM,D2_SERIE SERIEITEM,D2_CLIENTE CLIFORITEM,D2_LOJA LOJAITEM,D2_TIPO TIPOITEM
		,D2_GRADE GRADE,D2_COD COD ,D2_QUANT QUANT
		,D2_CF CF,D2_TES TES,D2_LOCAL ALMOX,D2_ITEMPV ITEMPV,D2_PEDIDO PEDIDO,D2_REMITO REMITO,D2_ITEMREM ITEMREM
		,D2_PRCVEN PRCVEN,%Exp:cExpTot% ,D2_DESCON VALDESC,D2_ITEM ITEM, "2" TIPODOC %Exp:cCamposD2%
FROM %Table:SF2% SF2, %Table:SD2% SD2, %Table:SA1% SA1
//WHERE	F2_FILIAL = %xFilial:SF2%
//		AND F2_DOC >= %Exp:mv_par01% AND F2_DOC <= %Exp:mv_par02%
WHERE	F2_DOC >= %Exp:mv_par01% AND F2_DOC <= %Exp:mv_par02%
		AND F2_EMISSAO >= %Exp:DTOS(mv_par03)%  AND F2_EMISSAO <= %Exp:DTOS(mv_par04)%
		AND F2_SERIE >= %Exp:mv_par06% AND F2_SERIE <= %Exp:mv_par07%
		AND F2_TIPO <> 'D'
		AND SF2.%notdel%
		AND SA1.A1_FILIAL = %xFilial:SA1% AND SA1.A1_COD = F2_CLIENTE AND SA1.A1_LOJA = F2_LOJA
		AND SA1.%notdel%
		AND D2_FILIAL = F2_FILIAL AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA
		AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE
		AND SD2.%notdel%
		%Exp:cWhereF2%		
			
UNION ALL
	
SELECT	F1_FILIAL FILIAL, F1_FORNECE CLIFOR,F1_LOJA LOJA,F1_DOC DOC,F1_SERIE SERIE,F1_DTDIGIT EMISSAO
		,F1_MOEDA MOEDA,F1_TXMOEDA TXMOEDA,F1_TIPO TIPO,F1_ESPECIE ESPECIE
		,F1_FRETE,0 FRETAUT,F1_SEGURO SEGURO,F1_DESPESA DESPESA
		,SA1.A1_NOME NOME,D1_DOC DOCITEM,D1_SERIE SERIEITEM,D1_FORNECE CLIFORITEM,D1_LOJA LOJAITEM,D1_TIPO TIPOITEM
		," " GRADE,D1_COD COD,D1_QUANT QUANT
		,D1_CF CF,D1_TES TES,D1_LOCAL ALMOX,D1_ITEMPV ITEMPV,D1_NUMPV PEDIDO,D1_REMITO REMITO,D1_ITEMREM ITEMREM
		,D1_VUNIT PRCVEN,D1_TOTAL TOTAL,0 VALADI,D1_VALDESC VALDESC,D1_ITEM ITEM, "1" TIPODOC %Exp:cCamposD1%
FROM %Table:SF1% SF1, %Table:SD1% SD1, %Table:SA1% SA1
//WHERE	F1_FILIAL = %xFilial:SF1%
//		AND F1_DOC >= %Exp:mv_par01% AND F1_DOC <= %Exp:mv_par02%
WHERE	F1_DOC >= %Exp:mv_par01% AND F1_DOC <= %Exp:mv_par02%
		AND F1_DTDIGIT >= %Exp:DtoS(mv_par03)% AND F1_DTDIGIT <= %Exp:DtoS(mv_par04)%
		AND F1_SERIE >= %Exp:mv_par06% AND F1_SERIE <= %Exp:mv_par07%
		AND F1_TIPO ='D'
		AND SF1.%notdel%
		AND SA1.A1_FILIAL = %xFilial:SA1% AND SA1.A1_COD = F1_FORNECE AND SA1.A1_LOJA=F1_LOJA
		AND SA1.%notdel%
		AND D1_FILIAL = F1_FILIAL AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA
		AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE
		AND SD1.%notdel%
		%Exp:cWhereF1%		
ORDER BY FILIAL, EMISSAO, TIPODOC,DOC,SERIE,COD,ITEM
EndSql
oReport:Section(1):EndQuery()

TcSetField(cAliasQry, 'EMISSAO', 'D', 08, 0  )
oReport:SetMeter((cAliasQry)->(LastRec()))
dbSelectArea(cAliasQry)
dbGoTop()
While !(cAliasQry)->(Eof()) .And. lContinua

	oReport:IncMeter()
	
	dEmisAnt    := (cAliasQry)->EMISSAO
	dEmissao    := (cAliasQry)->EMISSAO
	cDocFil		:= (cAliasQry)->FILIAL
	cNota		:= (cAliasQry)->DOC
	cTipo		:= (cAliasQry)->TIPO
	cTipoDoc	:= (cAliasQry)->TIPODOC
	cSerie		:= (cAliasQry)->SERIE
	cCliente	:= (cAliasQry)->CLIFOR + (cAliasQry)->LOJA
	cNome	  	:= (cAliasQry)->NOME
	cLoja		:= (cAliasQry)->LOJA
	nFrete		:= (cAliasQry)->FRETE
	nSeguro		:= (cAliasQry)->SEGURO
	nDespesa	:= (cAliasQry)->DESPESA
	nMoeda		:= (cAliasQry)->MOEDA
	nTxMoeda	:= (cAliasQry)->TXMOEDA
	nFretAut    := (cAliasQry)->FRETAUT	
	nCt         := 1
	
	If (cAliasQry)->TIPODOC == "1" 
		TRPrinD1Top(@nCt,oReport,cAliasQry)   
	Else	
		TRPrinD2Top(@nCt,oReport,cAliasQry)
	Endif

	nAcN3 := 0
	nTotNeto := 0
	If nAcN2 > 0
		nAcN3 := xmoeda(nFrete+nSeguro+nDespesa,nMoeda,mv_par13,dEmisAnt,nDecs+1,nTXMoeda) 
		nTotNeto := nAcN2+nAcN3+nFretAut+nAcImpInc

		If nAcN3 != 0 .Or. nFretAut != 0
			oReport:PrintText(STR0032 + " ------------> " + Str(nAcN3+nFretAut,14,2))		// DESPESAS ACESSORIAS
			oReport:SkipLine(1)			
		EndIf
		

		If cTipoDoc == "2" 
			nAcGImpInc  += nAcImpInc
			nAcGImpNoInc+= nAcImpNoInc
			nAcG1 += nAcN1
			nAcG2 += nAcN2
			nAcG3 += nAcN3+nFretAut
			nTotNetGer += nAcN2+nAcN3+nAcImpInc
		Else
			nAcGImpInc  -= nAcImpInc
			nAcGImpNoInc-= nAcImpNoInc
			nAcG1 -= nAcN1
			nAcG2 -= nAcN2
			nAcG3 -= nAcN3+nFretAut
			nTotNetGer -= nAcN2+nAcN3+nAcImpInc			
		Endif
	EndIf

	nTotDia += nAcN2+nAcImpInc
	nAcDImpInc  += nAcImpInc
	nAcDImpNoInc+= nAcImpNoInc
	nAcD1 		+= nAcN1
	nAcD2 		+= nAcN2
	nAcD3 		+= nAcN3+nFretAut	
	
	nAcImpInc   := 0
	nAcImpNoInc := 0
	nAcn1		:= 0
	nAcn2		:= 0
	nAcn3		:= 0

	If ( nAcd1 > 0 .And. ( dEmisAnt != (cAliasQry)->EMISSAO .Or. Eof() ))
		oReport:Section(6):SetHeaderSection(.F.)
		oReport:PrintText(STR0034 +  DtoC(dEmisAnt))
		oReport:FatLine() 
		oReport:Section(6):Init()
		oReport:Section(6):PrintLine()
		oReport:Section(6):Finish()
		oReport:SkipLine(2)
		
		nAcDImpInc  := 0
		nAcDImpNoInc:= 0
		nAcD1 		:= 0
		nAcD2 		:= 0
		nAcD3 		:= 0
		nTotDia		:= 0
		nAcdAdi		:= 0
	Endif

End // Documento, Serie

oReport:Section(5):SetHeaderSection(.F.)
oReport:PrintText(STR0060)
oReport:Section(5):Init()

oReport:Section(5):Cell("CCOD"):Hide()
oReport:Section(5):Cell("CDESC"	):Hide()
oReport:Section(5):Cell("ALMOX"):Hide()
oReport:Section(5):Cell("PEDIDO"):Hide()
oReport:Section(5):Cell("ITEM"):Hide()
oReport:Section(5):Cell("REMITO"):Hide()
oReport:Section(5):Cell("ITEMREM"):Hide()
oReport:Section(5):Cell("NACGIMPINC"):Hide()
oReport:Section(5):Cell("NACGIMPNOINC"):Hide()

oReport:Section(5):PrintLine()
oReport:Section(5):Finish()

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TRPrinD2Top� Autor � Marco Bianchi        � Data � 08/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime itens do SD2 (Base Localizada Top).                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550 - R4 	                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC Function TRPRIND2TOP(nCt,oReport,cAliasQry)

Local nTotImpInc  	:= 0
Local nTotImpNoInc	:= 0
Local nImpInc		:= 0
Local nImpNoInc		:= 0
Local nQuant		:= 0
Local nPrcVen		:= 0
Local nValadi		:= 0
Local nTotal		:= 0
Local nTotcImp		:= 0
Local cNumPed  		:= ""
Local nY       		:= 0 
Local cMascara 		:= GetMv("MV_MASCGRD")
Local nTamRef  		:= Val(Substr(cMascara,1,2))
Local nReg 			:= 0
Local cFilSF2       := "" 
Local cFilSD2       := "" 
Local lValadi		:= (cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0)

oReport:Section(2):Cell("CCLIENTE"	):SetBlock({|| Substr(cCliente,1,6)	})
oReport:Section(2):Cell("CLOJA"		):SetBlock({|| cLoja	})
oReport:Section(2):Cell("CNOME"		):SetBlock({|| cNome	})
oReport:Section(2):Cell("CEMISSAO"	):SetBlock({|| dEmissao	})
oReport:Section(2):Cell("CTIPO"		):SetBlock({|| cTipo	})

oReport:Section(4):Cell("CCOD"		):SetBlock({|| cCod			})
oReport:Section(4):Cell("ALMOX"		):SetBlock({|| cLocal		})
oReport:Section(4):Cell("CDESC"		):SetBlock({|| cDesc		})
oReport:Section(4):Cell("NQUANT"	):SetBlock({|| nQuant		})
oReport:Section(4):Cell("NPRCVEN"	):SetBlock({|| nPrcVen		})
If lValadi
	oReport:Section(4):Cell("NVALADI"	):SetBlock({|| nValadi		})
EndIf
oReport:Section(4):Cell("NTOTAL"	):SetBlock({|| nTotal		})
oReport:Section(4):Cell("NIMPINC"	):SetBlock({|| nImpInc		})
oReport:Section(4):Cell("NIMPNOINC"	):SetBlock({|| nImpnoInc	})
oReport:Section(4):Cell("NTOTCIMP"	):SetBlock({|| nTotcImp		})
oReport:Section(4):Cell("PEDIDO"	):SetBlock({|| cPedido		})
oReport:Section(4):Cell("ITEM"		):SetBlock({|| cItemPV		})
oReport:Section(4):Cell("REMITO"	):SetBlock({|| cRemito		})
oReport:Section(4):Cell("ITEMREM"	):SetBlock({|| cItemrem		})


nAcN1		:= 0
nAcN2		:= 0
nAcImpInc	:= 0
nAcImpnoInc	:= 0

If len(oReport:Section(2):GetAdvplExp("SF2")) > 0
   cFilSF2 := oReport:Section(2):GetAdvplExp("SF2")
EndIf
If len(oReport:Section(4):GetAdvplExp("SD2")) > 0
   cFilSD2 := oReport:Section(4):GetAdvplExp("SD2")
EndIf

While !Eof() .and. (cAliasQry)->DOC+(cAliasQry)->SERIE+(cAliasQry)->CLIFOR+(cAliasQry)->LOJA == cNota+cSerie+cCliente

	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSeek( (cAliasQry)->FILIAL + (cAliasQry)->DOC +(cAliasQry)->SERIE +(cAliasQry)->CLIFOR + (cAliasQry)->LOJA )
	// Verifica filtro do usuario
	If !Empty(cFilSF2) .And. !(&cFilSF2)
	   dbSelectArea(cAliasQry)	
       dbSkip()
	   Loop
	EndIf	
	        
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek( (cAliasQry)->FILIAL + (cAliasQry)->DOCITEM +(cAliasQry)->SERIEITEM +(cAliasQry)->CLIFORITEM + (cAliasQry)->LOJAITEM +(cAliasQry)->COD + (cAliasQry)->ITEM )
	// Verifica filtro do usuario
	If !Empty(cFilSD2) .And. !(&cFilSD2)
	   dbSelectArea(cAliasQry)	
       dbSkip()
   	   Loop
	EndIf	
	
	//���������������������������������������������Ŀ
	//� Valida o produto conforme a mascara         �
	//�����������������������������������������������
	dbSelectArea(cAliasQry)	
	lRet:=ValidMasc((cAliasQry)->COD,MV_PAR08)
	If !lRet
		dbSkip()
		Loop
	Endif

	If nCt == 1
		oReport:Section(2):Init()
		oReport:Section(2):PrintLine()
		oReport:Section(2):Finish()
		oReport:Section(4):Init()
		nCt++
	EndIf

	cCod := IIF((cAliasQry)->GRADE == "S".And. MV_PAR09 == 1,Substr((cAliasQry)->COD,1,nTamRef),(cAliasQry)->COD)
	//���������������������������������������������Ŀ
	//� Utiliza Descricao conforme mv_par12         �
	//�����������������������������������������������
	IF mv_par12 == 1
		dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasQry)->COD)
        cDesc := B1_DESC
	Else
		dbSelectArea("SA7");dbSetOrder(2)
		If dbSeek(xFilial()+(cAliasQry)->COD+(cAliasQry)->CLIFOR+(cAliasQry)->LOJA)
            cDesc := A7_DESCCLI
		Else
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasQry)->COD)
            cDesc := B1_DESC
		Endif
	Endif

	dbSelectArea(cAliasQry)
	cCf         := (cAliasQry)->CF
	cTes        := (cAliasQry)->TES
	cNumPed     := (cAliasQry)->PEDIDO
	nTotQuant   := 0
	nTotal      := 0
	nTotcImp    := 0
	nTotImpInc  := 0
	nTotImpNoInc:= 0
	nPrcVen     := xmoeda((cAliasQry)->PRCVEN,(cAliasQry)->MOEDA,mv_par13,,nDecs+1,(cAliasQry)->TXMOEDA)
	If lValadi
		nValadi := xmoeda((cAliasQry)->VALADI,(cAliasQry)->MOEDA,mv_par13,,nDecs+1,(cAliasQry)->TXMOEDA)
	EndIf	
    cLocal   := (cAliasQry)->ALMOX
    cPedido  := (cAliasQry)->PEDIDO
    cItemPV  := (cAliasQry)->ITEMPV
    cRemito  := (cAliasQry)->REMITO
    cItemRem := (cAliasQry)->ITEMREM

	nReg := 0
	If (cAliasQry)->GRADE == "S" .And. MV_PAR09 == 1
		cProdRef:= Substr((cAliasQry)->COD,1,nTamRef)
		cCod:= Substr((cAliasQry)->COD,1,nTamRef)
		While !Eof() .And. cProdRef == Substr((cAliasQry)->COD,1,nTamRef) ;
				.And. (cAliasQry)->GRADE == "S" .And. cNumPed == (cAliasQry)->PEDIDO
			nTotQuant+= (cAliasQry)->QUANT
			nTotal   += IIF(!((cAliasQry)->TIPO $ "IP"),xmoeda((cAliasQry)->TOTAL,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA),0)

			If (cAliasQry)->TIPO == "I"
				nCompIcm+=xmoeda((cAliasQry)->TOTAL,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
			EndIf

			nImpInc  := 0
			nImpNoInc:= 0

			aImpostos:=TesImpInf((cAliasQry)->TES)

			For nY:=1 to Len(aImpostos)
				cCampImp:=(cAliasQry)+"->"+(Substr(aImpostos[nY][2],4))
				If ( aImpostos[nY][3]=="1" )
					nImpInc     += xmoeda(&cCampImp,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
				Else
					nImpNoInc   += xmoeda(&cCampImp,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
				EndIf
			Next

			nTotImpInc     += nImpInc
			nTotImpNoInc   += nImpNoInc

			nReg     := Recno()

			dbSkip()

			//�������������������������������������������Ŀ
			//� Valida o produto conforme a mascara       �
			//���������������������������������������������
			lRet:=ValidMasc((cAliasQry)->COD,MV_PAR08)
			If !lRet
				dbSkip()
				Loop
			Endif
		End

		nTotcImp := (nTotal+nTotImpInc)
		nQuant  := nTotQuant
		oReport:Section(4):PrintLine()

		nAcN1       += nTotQuant
		nAcN2       += nTotal
		nAcImpInc   += nTotImpInc
		nAcImpNoInc += nTotImpNoInc

	Else
	
		nImpInc  := 0
		nImpNoInc:= 0

		aImpostos:=TesImpInf((cAliasQry)->TES)

		For nY:=1 to Len(aImpostos)
			cCampImp:=cAliasQry+"->"+(substr(aImpostos[nY][2],4))
			If ( aImpostos[nY][3]=="1" )
				nImpInc     += xmoeda(&cCampImp,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
			Else
				nImpNoInc   += xmoeda(&cCampImp,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
			EndIf
		Next

		cCod:= (cAliasQry)->COD
		nQuant := (cAliasQry)->QUANT
        nPrcVen :=  xMoeda((cAliasQry)->PRCVEN  ,(cAliasQry)->MOEDA,MV_PAR13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
        If lValadi
        	nValadi := xMoeda((cAliasQry)->VALADI  ,(cAliasQry)->MOEDA,MV_PAR13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
        EndIf
		nTotal :=  xMoeda((cAliasQry)->TOTAL	,(cAliasQry)->MOEDA,MV_PAR13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA) 
	    nTotcImp := nImpInc+xMoeda((cAliasQry)->TOTAL,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)

		oReport:Section(4):PrintLine()

		nAcImpInc   += nImpInc
		nAcImpNoInc += nImpNoInc

		nAcN1  += (cAliasQry)->QUANT
		nAcN2  += xmoeda((cAliasQry)->TOTAL,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)

	Endif

    If lValadi      	
       	nAcgAdi += nValadi
       	nAcdAdi += nValadi
    EndIf	
	
	dbSelectArea(cAliasQry)
	If nReg==0
		dbSkip()
	Endif
End // Nota   

If !(nQuant+nTotal+nImpInc+nImpNoInc+nTotcImp > 0)
	oReport:Section(4):AFunction := {}
	TRFunction():New(oReport:Section(4):Cell("NQUANT")		,/* cID */,"SUM",/*oBreak*/,STR0037,PesqPict("SD2","D2_QUANT"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(4):Cell("NTOTAL")		,/* cID */,"SUM",/*oBreak*/,STR0039,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(4):Cell("NIMPINC")	,/* cID */,"SUM",/*oBreak*/,STR0045,PesqPict("SD2","D2_VALIPI"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(4):Cell("NIMPNOINC")	,/* cID */,"SUM",/*oBreak*/,STR0046,PesqPict("SD2","D2_VALICM"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(4):Cell("NTOTCIMP")	,/* cID */,"SUM",/*oBreak*/,STR0047,PesqPict("SD2","D2_VALISS"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	oReport:SetTotalInLine(.F.)
Else
	oReport:Section(4):SetTotalText(STR0048 + " " +  cNota + "/" + cSerie)
	oReport:Section(4):Finish()
EndIf	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TRPrinD1Top� Autor � Marco Bianchi        � Data � 07/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime itens do SD1 (Base Localizada - Top).              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550 - R4		                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC Function TRPRIND1TOP(nCt,oReport,cAliasQry)

Local nY:=0
Local cFilSF1 := ""
Local cFilSD1 := ""
Local nQuant  := 0
Local nTotal := 0
Local nImpInc := 0
Local nImpNoInc := 0
Local nTotcImp := 0

oReport:Section(1):Cell("CCLIENTE"	):SetBlock({|| Substr(cCliente,1,6)	})
oReport:Section(1):Cell("CLOJA"		):SetBlock({|| cLoja	})
oReport:Section(1):Cell("CNOME"		):SetBlock({|| cNome	})
oReport:Section(1):Cell("CEMISSAO"	):SetBlock({|| dEmissao	})
oReport:Section(1):Cell("CTIPO"		):SetBlock({|| cTipo	})

oReport:Section(3):Cell("CCOD"		):SetBlock({|| cCod			})
oReport:Section(3):Cell("ALMOX"		):SetBlock({|| cLocal		})
oReport:Section(3):Cell("CDESC"		):SetBlock({|| cDesc		})
oReport:Section(3):Cell("NQUANT"	):SetBlock({|| nQuant		})
oReport:Section(3):Cell("NPRCVEN"	):SetBlock({|| nPrcVen 		})
oReport:Section(3):Cell("NTOTAL"	):SetBlock({|| nTotal		})
oReport:Section(3):Cell("NIMPINC"	):SetBlock({|| nImpInc 		})
oReport:Section(3):Cell("NIMPNOINC"	):SetBlock({|| nImpnoInc	})
oReport:Section(3):Cell("NTOTCIMP"	):SetBlock({||nTotcImp 		})
oReport:Section(3):Cell("PEDIDO"	):SetBlock({|| cPedido		})
oReport:Section(3):Cell("ITEM"		):SetBlock({|| cItemPV		})
oReport:Section(3):Cell("REMITO"	):SetBlock({|| cRemito		})
oReport:Section(3):Cell("ITEMREM"	):SetBlock({|| cItemrem		})
    
nAcN1		:= 0
nAcN2		:= 0
nAcImpInc	:= 0
nAcImpnoInc	:= 0
cPedido 	:= ""
cItemPV		:= ""
cRemito 	:= ""
cItemrem 	:= ""
cLocal      := ""

If len(oReport:Section(1):GetAdvplExp("SF1")) > 0
   cFilSF1 := oReport:Section(1):GetAdvplExp("SF1")
EndIf
If len(oReport:Section(3):GetAdvplExp("SD1")) > 0
   cFilSD1 := oReport:Section(3):GetAdvplExp("SD1")
EndIf


While !Eof() .and. (cAliasQry)->TIPODOC == "1" .And. (cAliasQry)->DOC+(cAliasQry)->SERIE+(cAliasQry)->CLIFOR+(cAliasQry)->LOJA == cNota+cSerie+cCliente
	

	dbSelectArea("SF1")
	dbSetOrder(1)
	dbSeek( (cAliasQry)->FILIAL + (cAliasQry)->DOC +(cAliasQry)->SERIE +(cAliasQry)->CLIFOR + (cAliasQry)->LOJA )
	// Verifica filtro do usuario
	If !Empty(cFilSF1) .And. !(&cFilSF1)
	   dbSelectArea(cAliasQry)	
       dbSkip()
	   Loop
	EndIf	
	        
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek( (cAliasQry)->FILIAL+ (cAliasQry)->DOCITEM +(cAliasQry)->SERIEITEM +(cAliasQry)->CLIFORITEM + (cAliasQry)->LOJAITEM +(cAliasQry)->COD + (cAliasQry)->ITEM )
	// Verifica filtro do usuario
	If !Empty(cFilSD1) .And. !(&cFilSD1)
	   dbSelectArea(cAliasQry)	
       dbSkip()
   	   Loop
	EndIf	

	//���������������������������������������������Ŀ
	//� Valida o produto conforme a mascara         �
	//�����������������������������������������������
	dbSelectArea(cAliasQry)
	lRet:=ValidMasc((cAliasQry)->COD,MV_PAR08)

	If !lRet
		dbSkip()
		Loop
	Endif

	If nCt == 1
		oReport:Section(1):Init()
		oReport:Section(1):PrintLine()
		oReport:Section(1):Finish()
		oReport:Section(3):Init()
		nCt++
	EndIf
	dbSelectArea(cAliasQry)

	nTotQuant   := 0
	nTotcImp    := 0
	nTotal      := 0
	nImpInc  	:= 0
	nImpNoInc	:= 0

	aImpostos:=TesImpInf((cAliasQry)->TES)
	For nY:=1 to Len(aImpostos)
		cCampImp:=cAliasQry+"->"+(Substr(aImpostos[nY][2],4))
		If ( aImpostos[nY][3]=="1" )
			nImpInc   += xmoeda(&cCampImp,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
		Else
			nImpNoInc += xmoeda(&cCampImp,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
		EndIf
	Next

	If mv_par12 == 1
		dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasQry)->COD)
        cDesc := B1_DESC
	Else
		dbSelectArea("SA7");dbSetOrder(2)
		If dbSeek(xFilial()+(cAliasQry)->COD+(cAliasQry)->CLIFOR+(cAliasQry)->LOJA)
            cDesc := A7_DESCCLI
		Else
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasQry)->COD)
            cDesc := B1_DESC
		Endif
	Endif
	
	dbSelectArea(cAliasQry)
	cCod:= (cAliasQry)->COD
	nQuant := (cAliasQry)->QUANT
	nPrcVen := xMoeda(((cAliasQry)->PRCVEN - ((cAliasQry)->VALDESC/(cAliasQry)->QUANT)) ,(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
	nTotal  := xMoeda(((cAliasQry)->TOTAL - (cAliasQry)->VALDESC),(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA) 
	nTotcImp := nImpInc+xmoeda(((cAliasQry)->TOTAL - (cAliasQry)->VALDESC),(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
    cLocal   := (cAliasQry)->ALMOX
    
	oReport:Section(3):PrintLine()

	nAcImpInc   += nImpInc
	nAcImpNoInc += nImpNoInc

	nAcN1  += (cAliasQry)->QUANT
	nAcN2  += xmoeda(((cAliasQry)->TOTAL - (cAliasQry)->VALDESC),(cAliasQry)->MOEDA,mv_par13,(cAliasQry)->EMISSAO,nDecs+1,(cAliasQry)->TXMOEDA)
	
	dbSelectArea(cAliasQry)
	dbSkip()
End 

If !(nQuant+nTotal+nImpInc+nImpNoInc+nTotcImp > 0)
	oReport:Section(3):aFunction := {}		// Zera array de totais
	TRFunction():New(oReport:Section(3):Cell("NQUANT")		,/* cID */,"SUM",/*oBreak*/,STR0037,PesqPict("SD2","D2_QUANT"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(3):Cell("NTOTAL")		,/* cID */,"SUM",/*oBreak*/,STR0039,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(3):Cell("NIMPINC")	,/* cID */,"SUM",/*oBreak*/,STR0045,PesqPict("SD2","D2_VALIPI"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(3):Cell("NIMPNOINC")	,/* cID */,"SUM",/*oBreak*/,STR0046,PesqPict("SD2","D2_VALICM"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(3):Cell("NTOTCIMP")	,/* cID */,"SUM",/*oBreak*/,STR0047,PesqPict("SD2","D2_VALISS"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	oReport:SetTotalInLine(.F.)
Else
	oReport:Section(3):SetTotalText(STR0048 + " " +  cNota + "/" + cSerie)
	oReport:Section(3):Finish()
EndIf	

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TRImpLocCB � Autor � Marco Bianchi        � Data � 07/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Relatorio Localizado                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TRImpLocCB(oReport)

Local nCt 		:= 0
Local lContinua := .T., dEmisAnt
Local cCondicao
Local lNovoDia := .F.  
Local cFilSF1           := "" 
Local cFilSF2           := "" 

Private aImpostos	:= {}
Private nDecs		:= MsDecimais(mv_par13)
Private cAliasSF2 	:= ""
Private cAliasSF1 	:= ""
Private cAliasSD1 	:= ""
Private cAliasSD2 	:= ""
Private cAliasPrt 	:= ""
Private nFrete   	:= 0
Private nFretAut 	:= 0
Private nSeguro  	:= 0
Private nDespesa 	:= 0
Private	nMoeda   	:= 0
Private	nTxMoeda 	:= 0
Private	cSerieNF 	:= ""

oReport:Section(1):Cell("CCLIENTE"	):SetBlock({|| Substr(cCliente,1,6)	})
oReport:Section(1):Cell("CLOJA"		):SetBlock({|| cLoja	})
oReport:Section(1):Cell("CNOME"		):SetBlock({|| cNome	})
oReport:Section(1):Cell("CEMISSAO"	):SetBlock({|| dEmissao	})
oReport:Section(1):Cell("CTIPO"		):SetBlock({|| cTipo	})

oReport:Section(2):Cell("CCLIENTE"	):SetBlock({|| Substr(cCliente,1,6)	})
oReport:Section(2):Cell("CLOJA"		):SetBlock({|| cLoja	})
oReport:Section(2):Cell("CNOME"		):SetBlock({|| cNome	})
oReport:Section(2):Cell("CEMISSAO"	):SetBlock({|| dEmissao	})
oReport:Section(2):Cell("CTIPO"		):SetBlock({|| cTipo	})

oReport:Section(5):Cell("NACG1"			):SetBlock({|| nAcG1		})
oReport:Section(5):Cell("NACG2"			):SetBlock({|| nAcG2 		})
oReport:Section(5):Cell("NACGIMPINC"	):SetBlock({|| nAcGImpInc 	})
oReport:Section(5):Cell("NACGIMPNOINC"	):SetBlock({|| nAcGImpNoInc	})
oReport:Section(5):Cell("NTOTNETGER"	):SetBlock({|| nTotNetGer	})

oReport:Section(6):Cell("NACD1"		):SetBlock({|| nAcD1		})
oReport:Section(6):Cell("NACD2"		):SetBlock({|| nAcD2 		})
oReport:Section(6):Cell("NTOTDIA"	):SetBlock({|| nTotDia	})

If mv_par17 == 2

	oReport:Section(3):SetHeaderSection(.F.)	// Desabilita Impressao Cabecalho no Topo da Pagina
	oReport:Section(4):SetHeaderSection(.T.)	// Desabilita Impressao Cabecalho no Topo da Pagina
	oReport:Section(3):Disable()
	
	If cPaisLoc # "PAR" .AND. cPaisLoc # "MEX"
		oReport:Section(4):Hide()
	EndIf
		
	oReport:Section(4):Acell[1]:SetTitle(Space(Len(oReport:Section(4):Acell[1]:GETTEXT())))	
	oReport:Section(4):Acell[2]:SetTitle(Space(Len(oReport:Section(4):Acell[2]:GETTEXT()))) 
	oReport:Section(4):Acell[3]:Disable()
	oReport:Section(4):Acell[4]:Disable()
	oReport:Section(4):Acell[5]:Disable()
	oReport:Section(4):Acell[6]:Disable()
	oReport:Section(4):Acell[7]:Disable()	
	
	oReport:Section(5):Acell[3]:Disable()
	oReport:Section(5):Acell[4]:Disable()
	oReport:Section(5):Acell[5]:Disable()
	oReport:Section(5):Acell[6]:Disable()
	oReport:Section(5):Acell[7]:Disable()
	
	oReport:Section(6):Acell[3]:Disable()
	oReport:Section(6):Acell[4]:Disable()
	oReport:Section(6):Acell[5]:Disable()
	oReport:Section(6):Acell[6]:Disable()
	oReport:Section(6):Acell[7]:Disable()		
EndIf

nAcG1		:= 0
nAcG2		:= 0
nAcGImpInc	:= 0
nAcGImpNoInc:= 0
nAcG3		:= 0
nTotNeto    := 0
nTotNetGer  := 0  
nTotDia 	:= 0
//����������������������������������������������������������������������������������������������������Ŀ
//�Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros para ambiente CDX �
//������������������������������������������������������������������������������������������������������
MakeAdvplExpr("MTR550P9R1") 

//��������������������������������������������������������������Ŀ
//� Cria Indice de Trabalho                                      �
//����������������������������������������������������������������
cAliasSF2 := "SF2"
cAliasSD2 := "SD2"
dbSelectArea("SF2")
cIndex	:= CriaTrab("",.F.)
cKey 	:= 'F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE'

//cCondicao := 'F2_FILIAL=="'+xFilial("SF2")+'".And.F2_DOC>="'+mv_par01+'"'
cCondicao := 'F2_DOC>="'+mv_par01+'"'
cCondicao += '.And.F2_DOC<="'+mv_par02+'".And.DTOS(F2_EMISSAO)>="'+DTOS(mv_par03)+'"'
cCondicao += '.And.DTOS(F2_EMISSAO)<="'+DTOS(mv_par04)+'".And. F2_SERIE>="'+mv_par06
cCondicao += '".And.F2_SERIE<= "'+mv_par07+'".And.F2_TIPO <> "D"'

If !Empty(mv_par16)
	cCondicao += '.And.'+mv_par16+''
EndIf	

cCondicao += '.And. !('+IsRemito(2,'SF2->F2_TIPODOC')+')'		

if mv_par14==2   //nao imprimir notas com moeda diferente da escolhida
	cCondicao+=" .And. F2_MOEDA==" + Alltrim(str(mv_par13))
endif

IndRegua("SF2",cIndex,cKey,,cCondicao)
nIndex := RetIndex("SF2")
dbSelectArea("SF2")
dbSetIndex(cIndex+OrdBagExt())
dbSetOrder(nIndex+1)
dbGoTop()


cAliasSF1 := "SF1"
cAliasSD1 := "SD1"
dbSelectArea("SF1")
cIndex1  := CriaTrab("",.F.)
cKey     := 'F1_FILIAL+DTOS(F1_DTDIGIT)+F1_DOC+F1_SERIE'

//cCondicao := 'F1_FILIAL=="'+xFilial("SF1")+'".And.F1_DOC>="'+mv_par01+'"'
cCondicao := 'F1_DOC>="'+mv_par01+'"'
cCondicao += '.And.F1_DOC<="'+mv_par02+'".And.DTOS(F1_DTDIGIT)>="'+DTOS(mv_par03)+'"'
cCondicao += '.And.DTOS(F1_DTDIGIT)<="'+DTOS(mv_par04)+'".And. F1_SERIE>="'+mv_par06
cCondicao += '".And.F1_SERIE<= "'+mv_par07+'".And.F1_TIPO == "D"'

If !Empty(mv_par16)
	cCondicao += '.And.'+StrTran(mv_par16,"F2_CLIENTE","F1_FORNECE")+''
EndIf	

cCondicao += '.And. !('+IsRemito(2,'SF1->F1_TIPODOC')+')'		

if mv_par14==2  //nao imprimir notas com moeda diferente da escolhida
	cCondicao+=" .And. F1_MOEDA==" + AllTrim(str(mv_par13))
endif

IndRegua("SF1",cIndex1,cKey,,cCondicao)
nIndex := RetIndex("SF1")
dbSelectArea("SF1")
dbSetIndex(cIndex1+OrdBagExt())
dbSetOrder(nIndex+1)
dbGoTop()

cDocFil		:= ""
cNota		:= ""
cSerie		:= ""
nAcN1		:= 0
nAcN2		:= 0
nAcImpInc	:= 0
nAcImpnoInc	:= 0
nAcDImpInc  := 0
nAcDImpNoInc:= 0
nAcD1		:= 0
nAcD2		:= 0
nAcD3		:= 0

dbSelectArea(cAliasSF2)
oReport:SetMeter((cAliasSF2)->(LastRec()))

If len(oReport:Section(1):GetAdvplExp("SF1")) > 0
   cFilSF1 := oReport:Section(1):GetAdvplExp("SF1")
EndIf

If len(oReport:Section(2):GetAdvplExp("SF2")) > 0
   cFilSF2 := oReport:Section(2):GetAdvplExp("SF2")
EndIf


While (!(cAliasSF1)->(Eof()) .Or. !(cAliasSF2)->(Eof()) ).And. lContinua

	
	oReport:IncMeter()
	nCt := 1
	If !(cAliasSF1)->(eof()) .And. If(!(cAliasSF2)->(EOF()),(cAliasSF2)->F2_EMISSAO > (cAliasSF1)->F1_DTDIGIT,.T.)

		// Verifica filtro do usuario
		If !Empty(cFilSF1) .And. !(&cFilSF1)
    	   dbSkip()
		   Loop
		EndIf	

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial()+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek((cAliasSF1)->F1_FILIAL+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

		cAliasPrt   := cAliasSF1
		dEmisAnt    := (cAliasSF1)->F1_DTDIGIT
		dEmissao    := (cAliasSF1)->F1_DTDIGIT
		cTipo	    := (cAliasSF1)->F1_TIPO
		cDocFil		:= (cAliasSF1)->F1_FILIAL
		cNota		:= (cAliasSF1)->F1_DOC
		cSerie  	:= (cAliasSF1)->F1_SERIE
		cSerieNF  	:= (cAliasSF1)->F1_SERIE
		cCliente	:= (cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA
		cLoja		:= (cAliasSF1)->F1_LOJA		
		nFrete		:= (cAliasSF1)->F1_FRETE
		nSeguro		:= (cAliasSF1)->F1_SEGURO
		nDespesa	:= (cAliasSF1)->F1_DESPESA
		nMoeda		:= (cAliasSF1)->F1_MOEDA
		nTxMoeda	:= (cAliasSF1)->F1_TXMOEDA
		cNome       := SA1->A1_NOME

		DbSelectArea(cAliasSD1)
		TRPrinD1CB(@nCt,oReport)
	ElseIf  !(cAliasSF2)->(Eof())
	
	
		// Verifica filtro do usuario
		If !Empty(cFilSF2) .And. !(&cFilSF2)
    	   dbSkip()
		   Loop
		EndIf	

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial()+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek((cAliasSF2)->F2_FILIAL+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)

		cAliasPrt   := cAliasSF2
		dEmisAnt    := (cAliasSF2)->F2_EMISSAO
		dEmissao    := (cAliasSF2)->F2_EMISSAO
		cTipo	    := (cAliasSF2)->F2_TIPO
		cDocFil		:= (cAliasSF2)->F2_FILIAL
		cNota		:= (cAliasSF2)->F2_DOC
		cSerie		:= (cAliasSF2)->F2_SERIE
		cSerieNF	:= (cAliasSF2)->F2_SERIE
		cCliente	:= (cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA
		Loja		:= (cAliasSF2)->F2_LOJA
		nFrete		:= (cAliasSF2)->F2_FRETE
		nFretAut    := (cAliasSF2)->F2_FRETAUT
		nSeguro		:= (cAliasSF2)->F2_SEGURO
		nDespesa	:= (cAliasSF2)->F2_DESPESA
		nMoeda		:= (cAliasSF2)->F2_MOEDA
		nTxMoeda	:= (cAliasSF2)->F2_TXMOEDA
		cLoja		:= (cAliasSF1)->F1_LOJA		
		cNome       := SA1->A1_NOME		
		DbSelectArea(cAliasSD2)
		TRPRIND2CB(@nCt,oReport)
	Endif

	nAcN3 := 0
	nTotNeto := 0
	If nAcN2 > 0
		nAcN3 := xmoeda(nFrete+nSeguro+nDespesa,nMoeda,mv_par13,dEmisAnt,nDecs+1,nTXMoeda)
		nTotNeto := nAcN2+nAcN3+nFretAut+nAcImpInc
		
		If nAcN3 != 0 .Or. nFretAut != 0
			oReport:PrintText(STR0032 + " ------------> " + Str(nAcN3+ nFretAut,14,2))		// DESPESAS ACESSORIAS
			oReport:SkipLine(1)			
		EndIf
	
		If cAliasPrt   == cAliasSF2
			nAcGImpInc  += nAcImpInc
			nAcGImpNoInc+= nAcImpNoInc
			nAcG1 += nAcN1
			nAcG2 += nAcN2
			nAcG3 += nAcN3+nFretAut
			nTotNetGer += nAcN2+nAcN3+nAcImpInc			
		Else
			nAcGImpInc  -= nAcImpInc
			nAcGImpNoInc-= nAcImpNoInc
			nAcG1 -= nAcN1
			nAcG2 -= nAcN2
			nAcG3 -= nAcN3+nFretAut
			nTotNetGer -= nAcN2+nAcN3+nAcImpInc			
		Endif

	EndIf

	nAcDImpInc  += nAcImpInc
	nAcDImpNoInc+= nAcImpNoInc
	nTotDia += nAcN2+nAcImpInc

	nAcD1 += nAcN1
	nAcD2 += nAcN2
	nAcD3 += nAcN3+nFretAut

	nAcImpInc   := 0
	nAcImpNoInc := 0

	nAcn1 := 0
	nAcn2 := 0
	nAcn3 := 0

	dbSelectArea(cAliasPrt)
	dbSkip()
	If cAliasPrt   == cAliasSF1
		lNovoDia := ( nAcd1 > 0 .And. ( dEmisAnt != F1_DTDIGIT .Or. Eof() ))
		dDia     := (cAliasPrt)->F1_DTDIGIT
	Else
		lNovoDia := ( nAcd1 > 0 .And. ( dEmisAnt != F2_EMISSAO .Or. Eof() ))
		dDia     := (cAliasPrt)->F2_EMISSAO
	Endif
	
	If lNovoDia
		oReport:Section(6):SetHeaderSection(.F.)
		oReport:PrintText(STR0034 +  DtoC(dEmisAnt))
		oReport:FatLine() 
		oReport:Section(6):Init()
		oReport:Section(6):PrintLine()
		oReport:Section(6):Finish()
		oReport:SkipLine(2)		
		nAcD1 := 0
		nAcD2 := 0
		nTotDia := 0
	EndIf

End // Documento, Serie

oReport:Section(5):SetHeaderSection(.F.)
oReport:PrintText(STR0060)
oReport:Section(5):Init()
oReport:Section(5):PrintLine()
oReport:Section(5):Finish()

//��������������������������������������������������������������Ŀ
//� Devolve condicao original ao SF2 e apaga arquivo de trabalho.�
//����������������������������������������������������������������
RetIndex("SF2")
dbSelectArea("SF2")
dbClearFilter()
dbSetOrder(1)

RetIndex("SF1")
dbSelectArea("SF1")
dbClearFilter()
dbSetOrder(1)

cIndex += OrdBagExt()
If File(cIndex)
	Ferase(cIndex)
Endif
cIndex1 += OrdBagExt()
If File(cIndex1)
	Ferase(cIndex1)
Endif


dbSelectArea("SD2")
dbSetOrder(1)

dbSelectArea("SD1")
dbSetOrder(1)

Return .T.



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TRPrinD1CB� Autor � Marco Bianchi         � Data � 09/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime itens do SD1 (Localizacoes - Code Base).           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550 - R4 	                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC Function TRPrinD1CB(nCt,oReport)

Local nY   := 0
Local cExpr:= ""
Local cFilSD1 := ""
Local nQuant := 0
Local nTotal := 0
Local nImpInc := 0
Local nImpNoInc := 0
Local nTotcImp := 0

oReport:Section(1):Cell("CCLIENTE"	):SetBlock({|| Substr(cCliente,1,6)	})
oReport:Section(1):Cell("CLOJA"		):SetBlock({|| cLoja	})
oReport:Section(1):Cell("CNOME"		):SetBlock({|| cNome	})
oReport:Section(1):Cell("CEMISSAO"	):SetBlock({|| dEmissao	})
oReport:Section(1):Cell("CTIPO"		):SetBlock({|| cTipo	})

oReport:Section(3):Cell("CCOD"		):SetBlock({|| cCod			})
oReport:Section(3):Cell("CDESC"		):SetBlock({|| cDesc		})
oReport:Section(3):Cell("NQUANT"	):SetBlock({|| nQuant		})
oReport:Section(3):Cell("NPRCVEN"	):SetBlock({|| nPrcVen 		})
oReport:Section(3):Cell("NTOTAL"	):SetBlock({|| nTotal		})
oReport:Section(3):Cell("NIMPINC"	):SetBlock({|| nImpInc 		})
oReport:Section(3):Cell("NIMPNOINC"	):SetBlock({|| nImpnoInc	})
oReport:Section(3):Cell("NTOTCIMP"	):SetBlock({||nTotcImp 		})
oReport:Section(3):Cell("PEDIDO"	):SetBlock({|| cPedido		})
oReport:Section(3):Cell("ITEM"		):SetBlock({|| cItemPV		})
oReport:Section(3):Cell("REMITO"	):SetBlock({|| cRemito		})
oReport:Section(3):Cell("ITEMREM"	):SetBlock({|| cItemrem		})

nAcN1		:= 0
nAcN2		:= 0
nAcImpInc	:= 0
nAcImpnoInc	:= 0
cPedido 	:= ""
cItemPV		:= ""
cRemito 	:= ""
cItemrem 	:= ""


If len(oReport:Section(3):GetAdvplExp("SD1")) > 0
   cFilSD1 := oReport:Section(3):GetAdvplExp("SD1")
EndIf

cExpr := IIf(!Empty(mv_par05),mv_par05,"")
cExpr += IIf(!Empty(cExpr),IIf(!Empty(mv_par10)," .AND. "+mv_par10,""),IIf(!Empty(mv_par10),mv_par10,""))
cExpr += IIf(!Empty(cExpr),IIf(!Empty(mv_par11)," .AND. "+mv_par11,""),IIf(!Empty(mv_par11),mv_par11,""))
cExpr := StrTran(cExpr, "D2_", "D1_")
While !Eof() .and. D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == cNota+cSerieNF+cCliente

	// Verifica filtro do usuario
	If !Empty(cFilSD1) .And. !(&cFilSD1)
		dbSelectArea(cAliasSD1)
       dbSkip()
   	   Loop
	EndIf	

	If !Empty(cExpr)
		If !(&(cExpr)) .Or. D1_SERIE < mv_par06 .Or. D1_SERIE > mv_par07 .Or. ;
		    TRIM(D1_ESPECIE) <> TRIM(SF1->F1_ESPECIE)				
			dbSkip()
			Loop
		Endif
	Else
		If D1_SERIE < mv_par06 .Or. D1_SERIE > mv_par07 .Or. ;
		    TRIM(D1_ESPECIE) <> TRIM(SF1->F1_ESPECIE)				
			dbSkip()
			Loop
		Endif
	Endif

	//���������������������������������������������Ŀ
	//� Valida o produto conforme a mascara         �
	//�����������������������������������������������
	lRet:=ValidMasc((cAliasSD1)->D1_COD,MV_PAR08)

	If !lRet
		dbSkip()
		Loop
	Endif

	If nCt == 1
		oReport:Section(1):Init()
		oReport:Section(1):PrintLine()
		oReport:Section(1):Finish()
		oReport:Section(3):Init()		
		nCt++
		dbSelectArea(cAliasSD1)
	EndIf

	dbSelectArea(cAliasSD1)
	nTotQuant   := 0
	nTotal      := 0
	nImpInc  := 0
	nImpNoInc:= 0

	aImpostos:=TesImpInf((cAliasSD1)->D1_TES)

	For nY:=1 to Len(aImpostos)
		cCampImp:=cAliasSD1+"->"+(aImpostos[nY][2])
		If ( aImpostos[nY][3]=="1" )
			nImpInc   += xmoeda(&cCampImp,(cAliasSF1)->F1_MOEDA,mv_par13,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
		Else
			nImpNoInc += xmoeda(&cCampImp,(cAliasSF1)->F1_MOEDA,mv_par13,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
		EndIf
	Next


	IF mv_par12 == 1
		dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD1)->D1_COD)
        cDesc := B1_DESC
	Else
		dbSelectArea("SA7");dbSetOrder(2)
		If dbSeek(xFilial()+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
            cDesc := A7_DESCCLI
		Else
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD1)->D1_COD)
            cDesc := B1_DESC
		Endif
	Endif

    dbSelectArea(cAliasSD1)
	cCod:= (cAliasSD1)->D1_COD
	cLocal:= (cAliasSD1)->D1_LOCAL
	nQuant := (cAliasSD1)->D1_QUANT
	nPrcVen := xMoeda((D1_VUNIT - (D1_VALDESC/D1_QUANT)) ,(cAliasSF1)->F1_MOEDA,mv_par13,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
	nTotal  := xMoeda((D1_TOTAL - D1_VALDESC),(cAliasSF1)->F1_MOEDA,mv_par13,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
	nTotcImp := nImpInc+xmoeda((D1_TOTAL - D1_VALDESC),(cAliasSF1)->F1_MOEDA,mv_par13,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
	
	oReport:Section(3):PrintLine()

	nAcImpInc   += nImpInc
	nAcImpNoInc += nImpNoInc
	nAcN1  		+= D1_QUANT
	nAcN2  		+= xmoeda((D1_TOTAL - D1_VALDESC),(cAliasSF1)->F1_MOEDA,mv_par13,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
	
	dbSelectArea(cAliasSD1)	
	dbSkip()
	
End // Nota

If !(nQuant+nTotal+nImpInc+nImpNoInc+nTotcImp > 0)
	oReport:Section(3):aFunction := {}		// Zera array de totais
	TRFunction():New(oReport:Section(3):Cell("NQUANT")		,/* cID */,"SUM",/*oBreak*/,STR0037,PesqPict("SD2","D2_QUANT"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(3):Cell("NTOTAL")		,/* cID */,"SUM",/*oBreak*/,STR0039,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(3):Cell("NIMPINC")	,/* cID */,"SUM",/*oBreak*/,STR0045,PesqPict("SD2","D2_VALIPI"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(3):Cell("NIMPNOINC")	,/* cID */,"SUM",/*oBreak*/,STR0046,PesqPict("SD2","D2_VALICM"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(3):Cell("NTOTCIMP")	,/* cID */,"SUM",/*oBreak*/,STR0047,PesqPict("SD2","D2_VALISS"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	oReport:SetTotalInLine(.F.)
Else
	oReport:Section(3):SetTotalText(STR0048 + " " +  cNota + "/" + cSerie)
	oReport:Section(3):Finish()
EndIf	


Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TRPrinD2CB� Autor � Marco Bianchi         � Data � 09/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime itens do SD2 (Localizacoes - Code Base).           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550 - R4	                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC Function TRPRIND2CB(nCt,oReport)


Local nQuant    	:= 0
Local nTotal    	:= 0
Local nTotcImp    	:= 0
Local nTotImpInc  	:= 0
Local nTotImpNoInc	:= 0
Local nImpInc		:= 0
Local nImpNoInc		:= 0
Local cNumPed  		:= ""
Local nY       		:= 0 
Local cMascara 		:= GetMv("MV_MASCGRD")
Local nTamRef  		:= Val(Substr(cMascara,1,2))
Local nReg 			:= 0
Local cExpr			:=""
Local cExprGrade	:=""
Local cFilSD2       := "" 

oReport:Section(2):Cell("CCLIENTE"	):SetBlock({|| Substr(cCliente,1,6)	})
oReport:Section(2):Cell("CLOJA"		):SetBlock({|| cLoja	})
oReport:Section(2):Cell("CNOME"		):SetBlock({|| cNome	})
oReport:Section(2):Cell("CEMISSAO"	):SetBlock({|| dEmissao	})
oReport:Section(2):Cell("CTIPO"		):SetBlock({|| cTipo	})

oReport:Section(4):Cell("CCOD"		):SetBlock({|| cCod			})
oReport:Section(4):Cell("CDESC"		):SetBlock({|| cDesc		})
oReport:Section(4):Cell("NQUANT"	):SetBlock({|| nQuant		})
oReport:Section(4):Cell("NPRCVEN"	):SetBlock({|| nPrcVen		})
oReport:Section(4):Cell("NTOTAL"	):SetBlock({|| nTotal		})
oReport:Section(4):Cell("NIMPINC"	):SetBlock({|| nImpInc		})
oReport:Section(4):Cell("NIMPNOINC"	):SetBlock({|| nImpnoInc	})
oReport:Section(4):Cell("NTOTCIMP"	):SetBlock({|| nTotcImp		})
oReport:Section(4):Cell("PEDIDO"	):SetBlock({|| cPedido		})
oReport:Section(4):Cell("ITEM"		):SetBlock({|| cItemPV		})
oReport:Section(4):Cell("REMITO"	):SetBlock({|| cRemito		})
oReport:Section(4):Cell("ITEMREM"	):SetBlock({|| cItemrem		})

nAcN1		:= 0
nAcN2		:= 0
nAcImpInc	:= 0
nAcImpnoInc	:= 0
cPedido		:= ""
cItemPV		:= ""
cRemito		:= ""
cItemrem	:= ""


cExpr := IIf(!Empty(mv_par05),mv_par05,"")
cExpr += IIf(!Empty(cExpr),IIf(!Empty(mv_par10)," .AND. "+mv_par10,""),IIf(!Empty(mv_par10),mv_par10,""))
cExprGrade := cExpr
cExpr += IIf(!Empty(cExpr),IIf(!Empty(mv_par11)," .AND. "+mv_par11,""),IIf(!Empty(mv_par11),mv_par11,""))

If len(oReport:Section(2):GetAdvplExp("SD2")) > 0
   cFilSD2 := oReport:Section(2):GetAdvplExp("SD2")
EndIf

While !Eof() .and. D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == cDocFil+cNota+cSerieNF+cCliente

	If !Empty(cExpr)
		If !(&(cExpr)) .Or. D2_SERIE < mv_par06 .Or. D2_SERIE > mv_par07 .Or. ;
		    TRIM(D2_ESPECIE) <> TRIM(SF2->F2_ESPECIE)				
			dbSkip()
			Loop
		Endif
	Else
		If D2_SERIE < mv_par06 .Or. D2_SERIE > mv_par07 .Or. ;
		    TRIM(D2_ESPECIE) <> TRIM(SF2->F2_ESPECIE)				
			dbSkip()
			Loop
		Endif
	Endif

	// Verifica filtro do usuario
	If !Empty(cFilSD2) .And. !(&cFilSD2)
   	   dbSkip()
  	   Loop
	EndIf	

	//���������������������������������������������Ŀ
	//� Valida o produto conforme a mascara         �
	//�����������������������������������������������
	lRet:=ValidMasc(SD2->D2_COD,MV_PAR08)
	If !lRet
		dbSkip()
		Loop
	Endif

	If nCt == 1
		oReport:Section(2):Init()
		oReport:Section(2):PrintLine()
		oReport:Section(2):Finish()
		oReport:Section(4):Init()
		nCt++
		dbSelectArea(cAliasSD2)
	EndIf

	cCod := IIF((cAliasSD2)->D2_GRADE == "S".And. MV_PAR09 == 1,Substr((cAliasSD2)->D2_COD,1,nTamRef),(cAliasSD2)->D2_COD)
	//���������������������������������������������Ŀ
	//� Utiliza Descricao conforme mv_par12         �
	//�����������������������������������������������
	IF mv_par12 == 1
		dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
        cDesc := B1_DESC
	Else
		dbSelectArea("SA7");dbSetOrder(2)
		If dbSeek(xFilial()+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
            cDesc := A7_DESCCLI
		Else
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
            cDesc := B1_DESC
		Endif
	Endif

	dbSelectArea(cAliasSD2)
	cCf         := D2_CF
	cTes        := D2_TES
	cCod        := D2_COD
	cLocal      := D2_LOCAL
	cItemPv     := D2_ITEMPV
	cPedido     := D2_PEDIDO
	cRemito     := D2_REMITO
	cItemRem    := D2_ITEMREM
	nTotQuant   := 0
	nTotal      := 0
	nTotImpInc  := 0
	nTotImpNoInc:= 0
	nPrcVen     := xmoeda(D2_PRCVEN,(cAliasSF2)->F2_MOEDA,mv_par13,,nDecs+1,(cAliasSF2)->F2_TXMOEDA)

	nReg := 0
	If (cAliasSD2)->D2_GRADE == "S" .And. MV_PAR09 == 1
		cProdRef:= Substr((cAliasSD2)->D2_COD,1,nTamRef)
		While !Eof() .And. cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef) ;
				.And. (cAliasSD2)->D2_GRADE == "S" .And. cNumPed == (cAliasSD2)->D2_PEDIDO
			nTotQuant+= (cAliasSD2)->D2_QUANT
			nTotal   += IIF(!((cAliasSF2)->F2_TIPO $ "IP"),xmoeda(D2_TOTAL,(cAliasSF2)->F2_MOEDA,mv_par13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA),0)

			If (cAliasSF2)->F2_TIPO == "I"
				nCompIcm+=xmoeda(D2_TOTAL,(cAliasSF2)->F2_MOEDA,mv_par13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
			EndIf

			nImpInc  := 0
			nImpNoInc:= 0

			aImpostos:=TesImpInf((cAliasSD2)->D2_TES)

			For nY:=1 to Len(aImpostos)
				cCampImp:=cAliasSD2+"->"+(aImpostos[nY][2])
				If ( aImpostos[nY][3]=="1" )
					nImpInc     += xmoeda(&cCampImp,(cAliasSF2)->F2_MOEDA,mv_par13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
				Else
					nImpNoInc   += xmoeda(&cCampImp,(cAliasSF2)->F2_MOEDA,mv_par13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
				EndIf
			Next

			nTotImpInc     += nImpInc
			nTotImpNoInc   += nImpNoInc

			nReg     := Recno()
			dbSkip()
			
			If !Empty(cExprGrade)
				If !(&(cExprGrade))
					dbSkip()
					Loop
				Endif
			Endif

			//�������������������������������������������Ŀ
			//� Valida o produto conforme a mascara       �
			//���������������������������������������������
			lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR08)
			If !lRet
				dbSkip()
				Loop
			Endif
		End

		If nReg > 0
			dbGoto(nReg)
			nReg:=0
		Endif

		nTotcImp := (nTotal+nTotImpInc)
		nQuant  := nTotQuant
		oReport:Section(4):PrintLine()

		nAcN1       += nTotQuant
		nAcN2       += nTotal
		nAcImpInc   += nTotImpInc
		nAcImpNoInc += nTotImpNoInc

	Else
	
		nImpInc  := 0
		nImpNoInc:= 0

		aImpostos:=TesImpInf((cAliasSD2)->D2_TES)

		For nY:=1 to Len(aImpostos)
			cCampImp:=cAliasSD2+"->"+(aImpostos[nY][2])
			If ( aImpostos[nY][3]=="1" )
				nImpInc     += xmoeda(&cCampImp,(cAliasSF2)->F2_MOEDA,mv_par13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
			Else
				nImpNoInc   += xmoeda(&cCampImp,(cAliasSF2)->F2_MOEDA,mv_par13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
			EndIf
		Next

		cCod     := (cAliasSD2)->D2_COD
		nQuant   := (cAliasSD2)->D2_QUANT
        nPrcVen  :=  xMoeda(D2_PRCVEN  ,(cAliasSF2)->F2_MOEDA,MV_PAR13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA) 
		nTotal   :=  xMoeda(D2_TOTAL	,(cAliasSF2)->F2_MOEDA,MV_PAR13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA) 
	    nTotcImp := nImpInc+xMoeda(D2_TOTAL,(cAliasSF2)->F2_MOEDA,mv_par13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
		oReport:Section(4):PrintLine()		
		
		nAcImpInc   += nImpInc
		nAcImpNoInc += nImpNoInc
		nAcN1  		+= (cAliasSD2)->D2_QUANT
		nAcN2  		+= xmoeda(D2_TOTAL,(cAliasSF2)->F2_MOEDA,mv_par13,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)

	Endif 
	
	dbSelectArea(cAliasSD2)	
	If nReg==0
		dbSkip()
	Endif
	
End // Nota

If !(nQuant+nTotal+nImpInc+nImpNoInc+nTotcImp > 0)
	oReport:Section(4):AFunction := {}
	TRFunction():New(oReport:Section(4):Cell("NQUANT")		,/* cID */,"SUM",/*oBreak*/,STR0037,PesqPict("SD2","D2_QUANT"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(4):Cell("NTOTAL")		,/* cID */,"SUM",/*oBreak*/,STR0039,PesqPict("SD2","D2_TOTAL"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(4):Cell("NIMPINC")	,/* cID */,"SUM",/*oBreak*/,STR0045,PesqPict("SD2","D2_VALIPI"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(4):Cell("NIMPNOINC")	,/* cID */,"SUM",/*oBreak*/,STR0046,PesqPict("SD2","D2_VALICM"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	TRFunction():New(oReport:Section(4):Cell("NTOTCIMP")	,/* cID */,"SUM",/*oBreak*/,STR0047,PesqPict("SD2","D2_VALISS"	),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)  
	oReport:SetTotalInLine(.F.)
Else
	oReport:Section(4):SetTotalText(STR0048 + " " +  cNota + "/" + cSerie)
	oReport:Section(4):Finish()
EndIf	


Return


//��������������������������������������������������������������Ŀ
//�                                                              �
//�                                                              �
//�                                                              �
//�                   R E L E A S E    3                         �
//�                                                              �
//�                                                              �
//�                                                              �
//����������������������������������������������������������������
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR550  � Autor � Claudinei M. Benzi    � Data � 04.05.92  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Notas Fiscais                                    ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe e � MATR550(void)                                               ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                                                             ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
��� Marcello     �23/08/00�oooooo�Impressao da relacao em outras moedas    ���
���              �        �      �funcao c550impint                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function VAFAR01R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL CbTxt
LOCAL CbCont,wnrel
LOCAL nOrdem,cFiltro := ""
LOCAL tamanho:= "G"
LOCAL limite := 220
LOCAL titulo := OemToAnsi(STR0001)	//"Relacao de Notas Fiscais"
LOCAL cDesc1 := OemToAnsi(STR0002)	//"Este programa ira emitir a relacao de notas fiscais."
LOCAL cDesc2 := ""
LOCAL cDesc3 := ""
LOCAL cString:= "SF2"

PRIVATE aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog:="MATR550"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="MTR550"

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont 	:= 0
li 		:= 80
m_pag 	:= 1
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������

pergunte("MTR550",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // De Nota                              �
//� mv_par02             // Ate a Nota                           �
//� mv_par03             // De Data                              �
//� mv_par04             // Ate a Data                           �
//� mv_par05             // De Produto                           �
//� mv_par06             // Ate o Produto                        �
//� mv_par07             // Da Serie                             �
//� mv_par08             // Da Serie                             �
//� mv_par09             // Mascara para codigo do produto       �
//� mv_par10             // Aglutina itens grade                 �
//� mv_par11             // De  Grupo                            �
//� mv_par12             // Ate Grupo                            �
//� mv_par13             // De  Tipo                             �
//� mv_par14             // Ate Tipo                             �
//� mv_par15             // Utiliza Descricao -Produto ProdxCli  �
//� mv_par16             // Qual Moeda                           �
//� mv_par17             // Outras moedas                        �
//� mv_par18             // Lista Dev. Compras ?                 �
//� mv_par19             // De Cliente                           �
//� mv_par20             // Ate Cliente                          �
//� mv_par21             // Tipo de Relatorio 1 Analitico 2      �
//� 						Sintetico                            �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:="MATR550"

// Foi retirado o filtro somente para Localizacoes
// Sergio Fuzinaka - 19.10.01
If cPaisLoc <> "BRA"
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)
Else
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
Endif

If nLastKey==27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
	Return
Endif

If ( cPaisLoc#"BRA" )
	RptStatus({|lEnd| C550ImpInt(@lEnd,wnRel,cString)},Titulo)
Else
	If mv_par21==1
		RptStatus({|lEnd| C550Imp(@lEnd,wnRel,cString)},Titulo)
	Else
   		RptStatus({|lEnd| C550ImpSin(@lEnd,wnRel,cString)},Titulo)
    Endif		 		
Endif
                 
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C550IMP  � Autor � Rosane Luciane Chene  � Data � 09.11.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C550Imp(lEnd,WnRel,cString)

LOCAL nCt := 0
LOCAL nAcD1  := 0, nAcD2 := 0, nAcD3 := 0, nAcD4 := 0, nAcD5 := 0, nAcD6:= 0, nAcD7 := 0
LOCAL nAcN1  := 0, nAcN2 := 0, nAcN3 := 0, nAcN4 := 0, nAcN5 := 0
LOCAL nAcN6  := 0, nAcG1 := 0, nAcG2 := 0, nAcG3 := 0, nAcG4 := 0
LOCAL nAcG5  := 0, nAcG6 := 0, nAcG7 := 0, nVlrISS := 0
LOCAL lContinua	:= .T., dEmisAnt
#IFDEF TOP
	LOCAL cQuery := ""
#ELSE
	LOCAL cCondicao
#ENDIF
LOCAL nReg     	:=0
LOCAL nTotQuant	:=0
LOCAL nTotal   	:=0
LOCAL nTotIcm  	:=0
LOCAL nTotIPI  	:=0
LOCAL nTotRet   :=0
LOCAL cCf      	:=""
LOCAL cTes    	:=""
LOCAL cLocal   	:=""
LOCAL cItemPv  	:=""
LOCAL cNumPed  	:=""
LOCAL nPrcVen  	:=0
LOCAL cMascara 	:=GetMv("MV_MASCGRD")
LOCAL nTamRef  	:=Val(Substr(cMascara,1,2))
LOCAL tamanho	:= "G"
LOCAL nICMDesp 	:= 0 , nIPIDesp:= 0
LOCAL cabec1,cabec2
Local dEmiDia := dDataBase
Local cNota   := ""
Local cSerie  := ""
Local nICMSRet:= 0
Local nFrete  := 0
Local nFretAut:= 0
Local nIcmAuto:= 0
Local nSeguro := 0
Local nDespesa:= 0
Local nValIPI := 0
Local nValICM := 0
Local nValISS := 0
Local cTipoNF := 0 
Local lFretAut:= GetNewPar("MV_FRETAUT",.T.)
Local lQuery  := .F.

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Imporessao do Cabecalho e Rodape   �
//����������������������������������������������������������������
cbtxt    := Space(10)
cbcont   := 00
li       := 80
m_pag    := 01
imprime  := .T.

//��������������������������������������������������������������Ŀ
//� Monta o Cabecalho de acordo com o tipo de emissao            �
//����������������������������������������������������������������
titulo := STR0005 + " - " + GetMv("MV_MOEDA" + STR(mv_par16,1)) //"RELACAO DAS NOTAS FISCAIS  "
Cabec1 := STR0006	//"PRODUTO          DESCRICAO                       QUANTIDADE        VALOR UNITARIO VALOR MERCADORIA ALMOX CFO TES PEDIDO/IT        VALOR IPI         VALOR ICM        VALOR ISS          DESP. ACESSORIAS               TOTAL"
// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
Cabec2 := " "
#IFDEF TOP    
    If TcSrvType()<>"AS/400"
    	lQuery := .T.
		cAliasSF2 := GetNextAlias()
		cAliasSD2 := cAliasSF2
		//campos do SF2
		cQuery:="SELECT F2_FILIAL, F2_DOC,F2_SERIE,F2_EMISSAO,F2_TIPO,F2_ICMSRET"
		cQuery+=",F2_FRETE,F2_FRETAUT,F2_ICMAUTO,F2_SEGURO,F2_DESPESA,F2_VALBRUT "
		cQuery+=",F2_VALIPI,F2_VALICM,F2_VALISS,SF2.R_E_C_N_O_ SF2RECNO "
		//campos do SD2
		cQuery+=",D2_DOC,D2_SERIE,D2_COD,D2_GRUPO,D2_TP,D2_TIPO,D2_CLIENTE,D2_LOJA,D2_GRADE,D2_CF,D2_TES,D2_LOCAL,D2_ITEMPV,D2_PEDIDO"
		cQuery+=",D2_PRCVEN,D2_ICMSRET,D2_QUANT,D2_TOTAL,D2_EMISSAO,D2_VALIPI,D2_CODISS,D2_VALISS,D2_VALICM "
		cQuery+="FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SD2")+" SD2 WHERE "
//		cQuery+="F2_FILIAL='"+xFilial("SF2")+"'"
//		cQuery+=" AND F2_DOC>='"+mv_par01+"' AND F2_DOC<='"+mv_par02+"'"
		cQuery+=" F2_DOC>='"+mv_par01+"' AND F2_DOC<='"+mv_par02+"'"
		cQuery+=" AND F2_EMISSAO>='"+DTOS(mv_par03)+"' AND F2_EMISSAO<='"+DTOS(mv_par04)+"'"
		cQuery+=" AND F2_SERIE>='"+mv_par07+"' AND F2_SERIE<='"+mv_par08+"'"
		cQuery+=" AND F2_CLIENTE>='"+mv_par19+"' AND F2_CLIENTE<='"+mv_par20+"'"
		cQuery+=" AND NOT ("+IsRemito(2,"F2_TIPODOC")+")"
		If MV_PAR18==2
			cQuery+=" AND F2_TIPO<>'D'"
		Endif
		cQuery+=" AND SF2.D_E_L_E_T_<>'*' "
//		cQuery+=" AND D2_FILIAL='"+xFilial("SD2")+"' AND D2_CLIENTE=F2_CLIENTE AND D2_LOJA=F2_LOJA"
		cQuery+=" AND D2_FILIAL=F2_FILIAL AND D2_CLIENTE=F2_CLIENTE AND D2_LOJA=F2_LOJA"
		cQuery+=" AND D2_DOC=F2_DOC AND D2_SERIE=F2_SERIE"
		cQuery+=" AND D2_COD>='"+mv_par05+"' AND D2_COD<='"+mv_par06+"'"
		cQuery+=" AND D2_GRUPO>='"+mv_par11+"' AND D2_GRUPO<='"+mv_par12+"'"
		cQuery+=" AND D2_TP>='"+mv_par13+"' AND D2_TP<='"+mv_par14+"'"
		cQuery+=" AND SD2.D_E_L_E_T_=''"
		cQuery+=" ORDER BY F2_FILIAL, F2_EMISSAO,F2_DOC,F2_SERIE,D2_COD,D2_ITEM"
		cQuery:=ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSF2,.F.,.T.)
		TCSetField(cAliasSF2,"F2_EMISSAO","D",8,0)
		TCSetField(cAliasSD2,"D2_EMISSAO","D",8,0)	
	Else
#ENDIF
		//��������������������������������������������������������������Ŀ
		//� Cria Indice de Trabalho                                      �
		//����������������������������������������������������������������
		cAliasSF2:="SF2"
		cAliasSD2:="SD2"
		dbSelectArea("SF2")
		cIndex := CriaTrab("",.F.)
		cKey := 'F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE'
		
//		cCondicao := 'F2_FILIAL=="'+xFilial("SF2")+'".And.F2_DOC>="'+mv_par01+'"'
		cCondicao := 'F2_DOC>="'+mv_par01+'"'
		cCondicao += '.And.F2_DOC<="'+mv_par02+'".And.DTOS(F2_EMISSAO)>="'+DTOS(mv_par03)+'"'
		cCondicao += '.And.DTOS(F2_EMISSAO)<="'+DTOS(mv_par04)+'".And. F2_SERIE>="'+mv_par07+'".And.F2_SERIE<= "'+mv_par08+'"'
		cCondicao += '.And.F2_CLIENTE>="'+mv_par19+'".And.F2_CLIENTE<="'+mv_par20+'"'
		cCondicao += '.And. !('+IsRemito(2,'SF2->F2_TIPODOC')+')'		
		If mv_par18 == 2
			cCondicao += '.And.F2_TIPO<>"D"'
		EndIf
		IndRegua("SF2",cIndex,cKey,,cCondicao)
		nIndex := RetIndex("SF2")
		
		dbSelectArea("SF2")
		#IFNDEF TOP
			dbSetIndex(cIndex+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGoTop()
#IFDEF TOP
	Endif    
#ENDIF

SetRegua(RecCount())		// Total de Elementos da regua

While !Eof() .and. lContinua

	IF lEnd
		@Prow()+1,001 PSAY STR0007		//"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	Endif

	IncRegua()

	dEmisAnt := F2_EMISSAO
	
	If !lQuery
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE)
	Endif

	nCt     := 1      
	nTotRet := 0
	cDocFil	:= (cAliasSF2)->F2_DOC
	cNota	:= (cAliasSF2)->F2_DOC
	cSerie	:= (cAliasSF2)->F2_SERIE
	nICMSRet:= (cAliasSF2)->F2_ICMSRET
	nFrete	:= (cAliasSF2)->F2_FRETE
	nFretAut:= (cAliasSF2)->F2_FRETAUT
	nIcmAuto:= (cAliasSF2)->F2_ICMAUTO
	nSeguro	:= (cAliasSF2)->F2_SEGURO
	nDespesa:= (cAliasSF2)->F2_DESPESA
	nValIPI	:= (cAliasSF2)->F2_VALIPI
	nValICM	:= (cAliasSF2)->F2_VALICM
	nValISS	:= (cAliasSF2)->F2_VALISS
	cTipoNF	:= (cAliasSF2)->F2_TIPO

	While !Eof() .and. D2_FILIAL+D2_DOC+D2_SERIE == cDocFil+cNota+cSerie

		If !lQuery
			If D2_COD < mv_par05 .Or. D2_COD > mv_par06 .Or. D2_GRUPO < mv_par11 .Or. ;
					D2_GRUPO > mv_par12 .Or. D2_TP < mv_par13 .Or. D2_TP > mv_par14 .Or. ;
					D2_SERIE < mv_par07 .Or. D2_SERIE > mv_par08
				dbSkip()
				Loop
			Endif
		Endif

		//���������������������������������������������Ŀ
		//� Valida o produto conforme a mascara         �
		//�����������������������������������������������
		lRet:=ValidMasc(SD2->D2_COD,MV_PAR09)

		If !lRet
			dbSkip()
			Loop
		Endif
		
		If !Empty(aReturn[7])
			If lQuery
				SF2->(MsGoto((cAliasSF2)->SF2RECNO))
			Endif
			If !SF2->(&(aReturn[7]))
				dbSkip()
				Loop			
		    EndIf
		EndIf

		If li > 52
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		EndIf

		If nCt == 1
			If (cAliasSD2)->D2_TIPO $ "BD"
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial()+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
                @Li ,   0 PSAY STR0008+A2_COD+" "+A2_LOJA+" - "+A2_NOME+" "+STR0009+DTOC((cAliasSF2)->F2_EMISSAO)+STR0010+(cAliasSD2)->D2_TIPO     //"FORNECEDOR : "###"EMISSAO : "###" TIPO DA NOTA : "
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial()+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
                @Li ,   0 PSAY STR0011+A1_COD+" "+A1_LOJA+" - "+A1_NOME+" "+STR0009+DTOC((cAliasSF2)->F2_EMISSAO)+STR0010+(cAliasSD2)->D2_TIPO     //"CLIENTE    : "###"EMISSAO : "###" TIPO DA NOTA : "
			EndIf
			nCt++
			Li++
			dbSelectArea((cAliasSD2))
		EndIf

		@Li , 0 PSAY IIF(D2_GRADE == "S".And. MV_PAR10 == 1,Substr(D2_COD,1,nTamRef),D2_COD)
		//���������������������������������������������Ŀ
		//� Utiliza Descricao conforme mv_par15         �
		//�����������������������������������������������
		IF mv_par15 == 1
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
            @li , 16 PSAY Substr(B1_DESC,1,29)
		Else
			dbSelectArea("SA7");dbSetOrder(2)
			If dbSeek(xFilial()+(cAliasSD2)->D2_COD+SD2->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
                @li , 16 PSAY Substr(A7_DESCCLI,1,29)
			Else
				dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
                @li , 16 PSAY Substr(B1_DESC,1,29)
			Endif
		Endif

		dbSelectArea(cAliasSD2)
		cCf      :=D2_CF
		cTes     :=D2_TES
		cLocal   :=D2_LOCAL
		cItemPv  :=D2_ITEMPV
		cNumPed  :=D2_PEDIDO
		nTotQuant:=0
		nTotal   :=0
		nTotICM  :=0
		nTotIPI  :=0
		nPrcVen  :=D2_PRCVEN

		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)
		
		If SF4->F4_INCSOL == "S"
			nTotRet += (cAliasSD2)->D2_ICMSRET
		Endif	

		dbSelectArea(cAliasSD2)

		nReg := 0
		If (cAliasSD2)->D2_GRADE == "S" .And. MV_PAR10 == 1
			cProdRef:= Substr((cAliasSD2)->D2_COD,1,nTamRef)
			While !Eof() .And. cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef) ;
					.And. (cAliasSD2)->D2_GRADE == "S" .And. cNumPed == D2_PEDIDO
				nTotQuant+= D2_QUANT
				nTotal   += D2_TOTAL
				nTotIPI  += D2_VALIPI

				If Empty(D2_CODISS) .And. SD2->D2_VALISS == 0 // ISS
					nTotIcm  += D2_VALICM
				EndIf
				nReg     := Recno()
				dbSkip()
				If !lQuery
					If SD2->D2_COD < mv_par05 .Or. SD2->D2_COD > mv_par06 .Or.;
							SD2->D2_GRUPO	< mv_par11 .Or. SD2->D2_GRUPO > mv_par12
						dbSkip()
						Loop
					Endif
				Endif
				//�������������������������������������������Ŀ
				//� Valida o produto conforme a mascara       �
				//���������������������������������������������
				lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR09)
				If !lRet
					dbSkip()
					Loop
				Endif
			End
			If !lQuery
				If nReg > 0
					dbGoto(nReg)
					nReg:=0
				Endif
			Endif

            @Li , 46 PSAY nTotQuant      PICTURE PESQPICTQT("D2_QUANT",16)
            @Li , 63 PSAY xMoeda(nPrcVen    ,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO) PICTURE PESQPICT("SD2","D2_PRCVEN",16)
            @Li , 80 PSAY xMoeda(nTotal     ,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO) PICTURE TM((D2_TOTAL),16)
            @Li ,100 PSAY cLocal
            @Li ,103 PSAY cCF
			@Li ,109 PSAY cTes
			@Li ,113 PSAY cNumPed
			@Li ,120 PSAY cItemPV
			@Li ,123 PSAY xMoeda(nTotIPI	,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO) PICTURE TM(D2_VALIPI,16)
			@Li ,141 PSAY xMoeda(nTotICM	,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO) PICTURE TM(D2_VALICM,16)
			nAcN1 += nTotQuant

			If SF4->F4_AGREG <> "N"   
			   nAcN2 += xMoeda(nTotal	,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
				If SF4->F4_AGREG == "D"
					nAcN2 -= xMoeda(nTotICM,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
				EndIf
            EndIf

			nAcN4 += xMoeda(nTotICM,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
			nAcN5 += xMoeda(nTotIPI,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
		Else
            @Li , 46 PSAY D2_QUANT       PICTURE PESQPICTQT("D2_QUANT",16)
            @Li , 63 PSAY xMoeda(D2_PRCVEN  ,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)    PICTURE PESQPICT("SD2","D2_PRCVEN",16)
            @Li , 80 PSAY xMoeda(D2_TOTAL   ,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)    PICTURE TM((D2_TOTAL),16)
            @Li ,100 PSAY D2_LOCAL
            @Li ,103 PSAY D2_CF
			@Li ,109 PSAY D2_TES
			@Li ,113 PSAY D2_PEDIDO
			@Li ,120 PSAY D2_ITEMPV
			@Li ,123 PSAY xMoeda(D2_VALIPI,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)	PICTURE TM(D2_VALIPI,16)
			
			If Empty(D2_CODISS) .And. SD2->D2_VALISS == 0 // ISS
				@Li ,141 PSAY xMoeda(D2_VALICM,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)	PICTURE TM(D2_VALICM,16)
			Endif
			nAcN1 += D2_QUANT

			If SF4->F4_AGREG <> "N"   
   			   nAcN2 += xMoeda(D2_TOTAL,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
			   If SF4->F4_AGREG == "D"
				   nAcN2 -= xMoeda(D2_VALICM,1,MV_PAR16,SD2->D2_EMISSAO)
			   EndIf
			Endif

			If Empty(D2_CODISS) .And. (cAliasSD2)->D2_VALISS == 0 // ISS
				nAcN4 += xMoeda(D2_VALICM,1,MV_PAR16,SD2->D2_EMISSAO)
			EndIf

			nAcN5 += xMoeda(D2_VALIPI,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
			
		Endif
		Li++
		dEmiDia := (cAliasSD2)->D2_EMISSAO
		If nReg==0
			dbSkip()
		Endif
	End // Nota

	If (nAcN2+nAcN4+nAcN5) # 0
		//��������������������������������������������������������������Ŀ
		//� Se nota tem ICMS Solidario, imprime.			             �
		//����������������������������������������������������������������
		If nICMSRet > 0
			@Li , 0   PSAY STR0012	//"ICMS SOLIDARIO ------------> "
			@Li , 204 PSAY nICMSRet Picture PesqPict("SF2","F2_ICMSRET",16)
			Li++
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Se nota tem ICMS Ref.Frete Autonomo, imprime.                �
		//����������������������������������������������������������������
		If nICMAuto > 0
			@Li , 0   PSAY STR0029	//"ICMS REF.FRETE AUTONOMO ---> "
			@Li , 204 PSAY nICMAuto Picture PesqPict("SF2","F2_ICMAUTO",16)
			Li++
		EndIf

		nAcN3 := xMoeda(nFrete+nSeguro+nDespesa,1,MV_PAR16,dEmiDia)
		If nAcN3 != 0 .Or. nFretAut != 0
			nIPIDesp := xMoeda(nValIPI,1,MV_PAR16,dEmiDia) - nAcN5
			nICMDesp := xMoeda(nValICM,1,MV_PAR16,dEmiDia) - nAcN4
			nAcN5 := xMoeda(nValIPI,1,MV_PAR16,dEmiDia)
			nAcN4 := xMoeda(nValICM,1,MV_PAR16,dEmiDia)
			@Li ,  0 PSAY STR0013	//"DESPESAS ACESSORIAS -------> "
			@Li ,123 PSAY nIPIDesp      PICTURE TM(D2_VALIPI	,16)
			@Li ,141 PSAY nICMDesp      PICTURE TM(D2_VALICM	,16)
			@Li ,184 PSAY nAcN3+nFretAut PICTURE TM(nAcN3		,16)
			Li++
		EndIf
		nAcN6 := nAcN2 + nAcN3 + nAcN5 + xMoeda(nTotRet,1,MV_PAR16,dEmiDia) +If(lFretAut,nIcmAuto,0)
		nVlrISS:= xMoeda(nValISS,1,MV_PAR16,dEmiDia)
		@Li ,   0 PSAY STR0014+cNota+" / "+cSerie+" ---->"		//"TOTAL DA NOTA - "
        @Li ,  46 PSAY nAcN1    PICTURE PESQPICTQT("D2_QUANT",16)
        @Li ,  80 PSAY nAcN2    PICTURE TM(nAcN2    ,16)
		@Li , 123 PSAY nAcN5    PICTURE TM(nAcN5	,16)
		@Li , 141 PSAY nAcN4    PICTURE TM(nAcN4	,16)
		@Li , 158 PSAY nVlrISS  PICTURE TM(nVlrISS	,16)
		@Li , 184 PSAY nAcN3+nFretAut PICTURE TM(nAcN3	,16)
		@Li , 204 PSAY nAcN6    PICTURE TM(nAcN6	,16)
		Li++
		@Li ,  0 PSAY __PrtThinLine()
		Li++
		nAcG1 += nAcN1
		nAcG2 += IIF(cTipoNF $ "IP",0,nAcN2)
		nAcG3 += nAcN3+nFretAut
		nAcG4 += nAcN4
		nAcG5 += nAcN5
		nAcG6 += IIF(cTipoNF $ "IP",0,nAcN6)
		nAcG7 += nVlrISS
	EndIf

	nAcD1 += nAcN1
	nAcD2 += IIF(cTipoNF $ "IP",0,nAcN2)
	nAcD3 += nAcN3+nFretAut
	nAcD4 += nAcN4
	nAcD5 += nAcN5
	nAcD6 += IIF(cTipoNF $ "IP",0,nAcN6)
	nAcD7 += nVlrISS

	nAcn1 := 0
	nAcn2 := 0
	nAcn3 := 0
	nAcn4 := 0
	nAcn5 := 0
	nAcn6 := 0
    nVlrISS := 0

	dbSelectArea(cAliasSF2)
	If !lQuery
		dbSkip()
	Endif

	If nAcd1+nAcD4+nAcD5 > 0 .And. ( dEmisAnt != F2_EMISSAO .Or. Eof() )
		Li++
		@Li ,  0 PSAY STR0015+dtoc(dEmisAnt)		//"TOTAL DO DIA  ----> "
        @Li , 46 PSAY nAcD1 PICTURE PESQPICTQT("D2_QUANT",16)
        @Li , 80 PSAY nAcD2 PICTURE TM(nAcD2,16)
		@Li ,123 PSAY nAcD5 PICTURE TM(nAcD5,16)
     	@Li ,141 PSAY nAcD4 PICTURE TM(nAcD4,16)
		@Li ,158 PSAY nAcD7 PICTURE TM(nAcD7,16)
		@Li ,184 PSAY nAcD3 PICTURE TM(nAcD3,16)
		@Li ,204 PSAY nAcD6 PICTURE TM(nAcD6,16)
		Li+=2
		nAcD1 := 0
		nAcD2 := 0
		nAcD3 := 0
		nAcD4 := 0
		nAcD5 := 0
		nAcD6 := 0
		nAcD7 := 0
	Endif

End // Documento, Serie
If nACG1 <> 0 .Or. nACG2 <> 0 .Or. nACG5 <> 0 .Or. nACG4 <> 0 .Or. nACG7 <> 0 .Or. nACG3 <> 0 .Or. nACG6 <> 0 
	IF li >= 52
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf
	
	@Li ,  0 PSAY STR0016	//"TOTAL GERAL            ---->"
	@Li , 46 PSAY nAcG1 PICTURE PESQPICTQT("D2_QUANT",16)
	@Li , 80 PSAY nAcG2 PICTURE TM(nAcG2,16)
	@Li ,123 PSAY nAcG5	PICTURE TM(nAcG5,16)
	@Li ,141 PSAY nAcG4	PICTURE TM(nAcG4,16)
	@Li ,158 PSAY nAcG7	PICTURE TM(nAcG7,16)
	@Li ,184 PSAY nAcG3	PICTURE TM(nAcG3,16)
	@Li ,204 PSAY nAcG6	PICTURE TM(nAcG6,16)
	Li++
	roda(cbcont,cbtxt,tamanho)
EndIf	
If lQuery
	DbSelectArea(cAliasSF2)
	DbCloseArea()
Else
	//��������������������������������������������������������������Ŀ
	//� Devolve condicao original ao SF2 e apaga arquivo de trabalho.�
	//����������������������������������������������������������������
	RetIndex("SF2")
	dbSelectArea("SF2")
	dbClearFilter()
	dbSetOrder(1)

	cIndex += OrdBagExt()
	If File(cIndex)
		Ferase(cIndex)
	Endif
Endif

dbSelectArea("SD2")
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C550IMPSIM� Autor � Rosane Luciane Chene  � Data � 09.11.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C550ImpSin(lEnd,WnRel,cString)

LOCAL nCt := 0
LOCAL dDatAnt:= CTOD('  /  /  ')
LOCAL nAcD1  := 0, nAcD2 := 0, nAcD3 := 0, nAcD4 := 0, nAcD5 := 0, nAcD6:= 0, nAcD7 := 0
LOCAL nAcN1  := 0, nAcN2 := 0, nAcN3 := 0, nAcN4 := 0, nAcN5 := 0
LOCAL nAcN6  := 0, nAcG1 := 0, nAcG2 := 0, nAcG3 := 0, nAcG4 := 0
LOCAL nAcG5  := 0, nAcG6 := 0, nAcG7 := 0, nVlrISS := 0
LOCAL lContinua	:= .T., dEmisAnt
LOCAL cCondicao
LOCAL nReg     	:=0
LOCAL nTotQuant	:=0
LOCAL nTotal   	:=0
LOCAL nTotIcm  	:=0
LOCAL nTotIPI  	:=0
LOCAL nTotRet   :=0
LOCAL cCf      	:=""
LOCAL cTes    	:=""
LOCAL cLocal   	:=""
LOCAL cItemPv  	:=""
LOCAL cNumPed  	:=""
LOCAL nPrcVen  	:=0
LOCAL cMascara 	:=GetMv("MV_MASCGRD")
LOCAL nTamRef  	:=Val(Substr(cMascara,1,2))
LOCAL nTamLin  	:=Val(Substr(cMascara,4,2))
LOCAL nTamCol  	:=Val(Substr(cMascara,7,2))
LOCAL tamanho	:= "G"
LOCAL limite 	:= 220
LOCAL nICMDesp 	:= 0 , nIPIDesp:= 0
LOCAL cabec1,cabec2,cabec3
Local dEmiDia := dDataBase
Local cNota   := ""
Local cSerie  := ""
Local nICMSRet:= 0
Local nFrete  := 0
Local nFretAut:= 0
Local nIcmAuto:= 0
Local nSeguro := 0
Local nDespesa:= 0
Local nValIPI := 0
Local nValICM := 0
Local nValISS := 0
Local cTipoNF := 0 
Local lFretAut:= GetNewPar("MV_FRETAUT",.T.)
Local lQuery  := .F.
Local lCompIPI	:= .F.

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Imporessao do Cabecalho e Rodape   �
//����������������������������������������������������������������
cbtxt    := Space(10)
cbcont   := 00
li       := 80
m_pag    := 01
imprime  := .T.

//��������������������������������������������������������������Ŀ
//� Monta o Cabecalho de acordo com o tipo de emissao            �
//����������������������������������������������������������������


titulo := STR0005 + " - " + GetMv("MV_MOEDA" + STR(mv_par16,1)) //"RELACAO DAS NOTAS FISCAIS  "  
Cabec1 := STR0028	//"DETALHES DAS NOTAS                             QUANTIDADE        VALOR UNITARIO VALOR MERCADORIA ARMAZ CFO   TES PEDIDO/IT        VALOR IPI         VALOR ICM        VALOR ISS          DESP. ACESSORIAS               TOTAL"	
// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
Cabec2 := " "
#IFDEF TOP       
    If TcSrvType()<>"AS/400"  
		lQuery := .T.
		cAliasSF2 := GetNextAlias()
		cAliasSD2 := cAliasSF2
		//campos do SF2
		cQuery:="SELECT F2_FILIAL, F2_DOC,F2_SERIE,F2_EMISSAO,F2_TIPO,F2_ICMSRET"
		cQuery+=",F2_FRETE,F2_FRETAUT,F2_ICMAUTO,F2_SEGURO,F2_DESPESA,F2_VALBRUT"
		cQuery+=",F2_VALIPI,F2_VALICM,F2_VALISS,SF2.R_E_C_N_O_ SF2RECNO "
		//campos do SD2
		cQuery+=",D2_DOC,D2_SERIE,D2_COD,D2_GRUPO,D2_TP,D2_TIPO,D2_CLIENTE,D2_LOJA,D2_GRADE,D2_CF,D2_TES,D2_LOCAL,D2_ITEMPV,D2_PEDIDO"
		cQuery+=",D2_PRCVEN,D2_ICMSRET,D2_QUANT,D2_TOTAL,D2_EMISSAO,D2_VALIPI,D2_CODISS,D2_VALISS,D2_VALICM "
		cQuery+="FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SD2")+" SD2 WHERE "
//		cQuery+="F2_FILIAL='"+xFilial("SF2")+"'"
//		cQuery+=" AND F2_DOC>='"+mv_par01+"' AND F2_DOC<='"+mv_par02+"'"
		cQuery+=" F2_DOC>='"+mv_par01+"' AND F2_DOC<='"+mv_par02+"'"
		cQuery+=" AND F2_EMISSAO>='"+DTOS(mv_par03)+"' AND F2_EMISSAO<='"+DTOS(mv_par04)+"'"
		cQuery+=" AND F2_SERIE>='"+mv_par07+"' AND F2_SERIE<='"+mv_par08+"'"
		cQuery+=" AND F2_CLIENTE>='"+mv_par19+"' AND F2_CLIENTE<='"+mv_par20+"'"
		cQuery+=" AND NOT ("+IsRemito(2,"F2_TIPODOC")+")"
		If MV_PAR18==2
			cQuery+=" AND F2_TIPO<>'D'"
		Endif
		cQuery+=" AND SF2.D_E_L_E_T_<>'*' "
		cQuery+=" AND D2_FILIAL=F2_FILIAL AND D2_CLIENTE=F2_CLIENTE AND D2_LOJA=F2_LOJA"
		cQuery+=" AND D2_DOC=F2_DOC AND D2_SERIE=F2_SERIE"
		cQuery+=" AND D2_COD>='"+mv_par05+"' AND D2_COD<='"+mv_par06+"'"
		cQuery+=" AND D2_GRUPO>='"+mv_par11+"' AND D2_GRUPO<='"+mv_par12+"'"
		cQuery+=" AND D2_TP>='"+mv_par13+"' AND D2_TP<='"+mv_par14+"'"
		cQuery+=" AND SD2.D_E_L_E_T_=''"
		cQuery+=" ORDER BY F2_FILIAL, F2_EMISSAO,F2_DOC,F2_SERIE,D2_COD,D2_ITEM"
		cQuery:=ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSF2,.F.,.T.)
		TCSetField(cAliasSF2,"F2_EMISSAO","D",8,0)
		TCSetField(cAliasSD2,"D2_EMISSAO","D",8,0)
	Else
#ENDIF
		//��������������������������������������������������������������Ŀ
		//� Cria Indice de Trabalho                                      �
		//����������������������������������������������������������������
		cAliasSF2:="SF2"
		cAliasSD2:="SD2"
		dbSelectArea("SF2")
		cIndex := CriaTrab("",.F.)
		cKey := 'F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE'
	
//		cCondicao := 'F2_FILIAL=="'+xFilial("SF2")+'".And.F2_DOC>="'+mv_par01+'"'
		cCondicao := 'F2_DOC>="'+mv_par01+'"'
		cCondicao += '.And.F2_DOC<="'+mv_par02+'".And.DTOS(F2_EMISSAO)>="'+DTOS(mv_par03)+'"'
		cCondicao += '.And.DTOS(F2_EMISSAO)<="'+DTOS(mv_par04)+'".And. F2_SERIE>="'+mv_par07+'".And.F2_SERIE<= "'+mv_par08+'"'
		cCondicao += '.And.F2_CLIENTE>="'+mv_par19+'".And.F2_CLIENTE<="'+mv_par20+'"'
		cCondicao += '.And. !('+IsRemito(2,'SF2->F2_TIPODOC')+')'		
		If mv_par18 == 2
			cCondicao += '.And.F2_TIPO<>"D"'
		EndIf
		IndRegua("SF2",cIndex,cKey,,cCondicao)
		nIndex := RetIndex("SF2")
	
		dbSelectArea("SF2")
		#IFNDEF TOP
			dbSetIndex(cIndex+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGoTop()
#IFDEF TOP
	Endif    
#ENDIF

SetRegua(RecCount())		// Total de Elementos da regua

While !Eof() .and. lContinua

	IF lEnd
		@Prow()+1,001 PSAY STR0007		//"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	Endif

	IncRegua()

	dEmisAnt := F2_EMISSAO
	
	If !lQuery
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE)
	Endif

	nCt     := 1      
	nTotRet := 0
	cDocFil	:= (cAliasSF2)->F2_DOC
	cNota	:= (cAliasSF2)->F2_DOC
	cSerie	:= (cAliasSF2)->F2_SERIE
	nICMSRet:= (cAliasSF2)->F2_ICMSRET
	nFrete	:= (cAliasSF2)->F2_FRETE
	nFretAut:= (cAliasSF2)->F2_FRETAUT	
	nIcmAuto:= (cAliasSF2)->F2_ICMAUTO
	nSeguro	:= (cAliasSF2)->F2_SEGURO
	nDespesa:= (cAliasSF2)->F2_DESPESA
	nValIPI	:= (cAliasSF2)->F2_VALIPI
	nValICM	:= (cAliasSF2)->F2_VALICM
	nValISS	:= (cAliasSF2)->F2_VALISS
	cTipoNF	:= (cAliasSF2)->F2_TIPO
	
	While !Eof() .and. D2_FILIAL+D2_DOC+D2_SERIE == cDocFil+cNota+cSerie

		If !lQuery
			If D2_COD < mv_par05 .Or. D2_COD > mv_par06 .Or. D2_GRUPO < mv_par11 .Or. ;
					D2_GRUPO > mv_par12 .Or. D2_TP < mv_par13 .Or. D2_TP > mv_par14 .Or. ;
					D2_SERIE < mv_par07 .Or. D2_SERIE > mv_par08
				dbSkip()
				Loop
			Endif
		Endif

		//���������������������������������������������Ŀ
		//� Valida o produto conforme a mascara         �
		//�����������������������������������������������
		lRet:=ValidMasc(SD2->D2_COD,MV_PAR09)

		If !lRet
			dbSkip()
			Loop
		Endif

		If !Empty(aReturn[7])
			If lQuery
				SF2->(MsGoto((cAliasSF2)->SF2RECNO))
			Endif
			If !SF2->(&(aReturn[7]))
				dbSkip()
				Loop			
		    EndIf
		EndIf
		
		If li > 52
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		EndIf

		If nCt == 1
			If (cAliasSD2)->D2_TIPO $ "BD"
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial()+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)

			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial()+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)

			EndIf
			nCt++
			Li++
			dbSelectArea((cAliasSD2))
		EndIf


		//���������������������������������������������Ŀ
		//� Utiliza Descricao conforme mv_par15         �
		//�����������������������������������������������
		IF mv_par15 == 1
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)

		Else
			dbSelectArea("SA7");dbSetOrder(2)
			If dbSeek(xFilial()+(cAliasSD2)->D2_COD+SD2->D2_CLIENTE+(cAliasSD2)->D2_LOJA)

			Else
			 	dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)

			Endif
		Endif

		dbSelectArea(cAliasSD2)
		cCf      :=D2_CF
		cTes     :=D2_TES
		cLocal   :=D2_LOCAL
		cItemPv  :=D2_ITEMPV
		cNumPed  :=D2_PEDIDO
		nTotQuant:=0
		nTotal   :=0
		nTotICM  :=0
		nTotIPI  :=0
		nPrcVen  :=D2_PRCVEN

		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)
		
		If SF4->F4_INCSOL == "S"
			nTotRet += (cAliasSD2)->D2_ICMSRET
		Endif	

		dbSelectArea(cAliasSD2)

		nReg := 0
		If (cAliasSD2)->D2_GRADE == "S" .And. MV_PAR10 == 1
			cProdRef:= Substr((cAliasSD2)->D2_COD,1,nTamRef)
			While !Eof() .And. cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef) ;
					.And. (cAliasSD2)->D2_GRADE == "S" .And. cNumPed == D2_PEDIDO
				nTotQuant+= D2_QUANT
				nTotal   += D2_TOTAL
				nTotIPI  += D2_VALIPI

				If Empty(D2_CODISS) .And. SD2->D2_VALISS == 0 // ISS
					nTotIcm  += D2_VALICM
				EndIf
				nReg     := Recno()
				dbSkip()
				If !lQuery
					If SD2->D2_COD < mv_par05 .Or. SD2->D2_COD > mv_par06 .Or.;
							SD2->D2_GRUPO	< mv_par11 .Or. SD2->D2_GRUPO > mv_par12
						dbSkip()
						Loop
					Endif
				Endif
				//�������������������������������������������Ŀ
				//� Valida o produto conforme a mascara       �
				//���������������������������������������������
				lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR09)
				If !lRet
					dbSkip()
					Loop
				Endif
			End
			
			If !lQuery
				If nReg > 0
					dbGoto(nReg)
					nReg:=0
				Endif
			Endif

    		nAcN1 += nTotQuant

			If SF4->F4_AGREG <> "N"   
			   nAcN2 += xMoeda(nTotal	,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
			   If SF4->F4_AGREG == "D"
				   nAcN2 -= xMoeda(nTotICM,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
			   EndIf
            EndIf

			nAcN4 += xMoeda(nTotICM,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
			nAcN5 += xMoeda(nTotIPI,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
		Else
    		
			If Empty(D2_CODISS) .And. SD2->D2_VALISS == 0 // ISS
	
			Endif
			nAcN1 += D2_QUANT

			If SF4->F4_AGREG <> "N"   
   			   nAcN2 += xMoeda(D2_TOTAL,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
				If SF4->F4_AGREG = "D"
					nAcN2 -= xMoeda(D2_VALICM,1,MV_PAR16,SD2->D2_EMISSAO)
				EndIf
			Endif

			If Empty(D2_CODISS) .And. (cAliasSD2)->D2_VALISS == 0 // ISS
				nAcN4 += xMoeda(D2_VALICM,1,MV_PAR16,SD2->D2_EMISSAO)
			EndIf

			nAcN5 += xMoeda(D2_VALIPI,1,MV_PAR16,(cAliasSD2)->D2_EMISSAO)
			
			If (cAliasSD2)->D2_TIPO == "P"
				lCompIPI := .T.
			EndIf
			
		Endif
		dEmiDia := (cAliasSD2)->D2_EMISSAO
		If nReg==0
			dbSkip()
		Endif
	End // Nota

	If (nAcN2+nAcN4+nAcN5) # 0
		nAcN3 := xMoeda(nFrete+nSeguro+nDespesa,1,MV_PAR16,dEmiDia)
		If nAcN3 != 0 .Or. nFretAut != 0
			nIPIDesp := xMoeda(nValIPI,1,MV_PAR16,dEmiDia) - nAcN5
			nICMDesp := xMoeda(nValICM,1,MV_PAR16,dEmiDia) - nAcN4
			nAcN5 := xMoeda(nValIPI,1,MV_PAR16,dEmiDia)
			nAcN4 := xMoeda(nValICM,1,MV_PAR16,dEmiDia)
		EndIf
		If !lCompIPI
			nAcN6 := nAcN2 + nAcN3 + nAcN5 + xMoeda(nTotRet,1,MV_PAR16,dEmiDia) +If(lFretAut,nIcmAuto,0)
		Else
			nAcN6 := nAcN5
		EndIf	
		nVlrISS:= xMoeda(nValISS,1,MV_PAR16,dEmiDia)
	  	@Li ,   0 PSAY STR0014+cNota+" / "+cSerie+" ---->"		//"TOTAL DA NOTA - "
        @Li ,  46 PSAY nAcN1    PICTURE PESQPICTQT("D2_QUANT",16)
        @Li ,  80 PSAY nAcN2    PICTURE TM(nAcN2    ,16)
		@Li , 123 PSAY nAcN5    PICTURE TM(nAcN5	,16)
		@Li , 141 PSAY nAcN4    PICTURE TM(nAcN4	,16)
		@Li , 158 PSAY nVlrISS  PICTURE TM(nVlrISS	,16)
		@Li , 184 PSAY nAcN3+nFretAut PICTURE TM(nAcN3	,16)
		@Li , 204 PSAY nAcN6    PICTURE TM(nAcN6	,16)
		Li++
		@Li ,  0 PSAY __PrtThinLine()
		Li++
		nAcG1 += nAcN1
		nAcG2 += IIF(cTipoNF $ "IP",0,nAcN2)
		nAcG3 += nAcN3+nFretAut
		nAcG4 += nAcN4
		nAcG5 += nAcN5
		nAcG6 += IIF(cTipoNF $ "IP",0,nAcN6)
		nAcG7 += nVlrISS
	EndIf

	nAcD1 += nAcN1
	nAcD2 += IIF(cTipoNF $ "IP",0,nAcN2)
	nAcD3 += nAcN3+nFretAut
	nAcD4 += nAcN4
	nAcD5 += nAcN5
	nAcD6 += IIF(cTipoNF $ "IP",0,nAcN6)
	nAcD7 += nVlrISS

	nAcn1 := 0
	nAcn2 := 0
	nAcn3 := 0
	nAcn4 := 0
	nAcn5 := 0
	nAcn6 := 0
    nVlrISS := 0
	
	dbSelectArea(cAliasSF2)
	If !lQuery
		dbSkip()
	Endif

	If nAcd1+nAcD4+nAcD5 > 0 .And. ( dEmisAnt != F2_EMISSAO .Or. Eof() )
		Li++
	   	@Li ,  0 PSAY STR0015+dtoc(dEmisAnt)		//"TOTAL DO DIA  ----> "
        @Li , 46 PSAY nAcD1 PICTURE PESQPICTQT("D2_QUANT",16)
        @Li , 80 PSAY nAcD2 PICTURE TM(nAcD2,16)
		@Li ,123 PSAY nAcD5 PICTURE TM(nAcD5,16)
     	@Li ,141 PSAY nAcD4 PICTURE TM(nAcD4,16)
		@Li ,158 PSAY nAcD7 PICTURE TM(nAcD7,16)
		@Li ,184 PSAY nAcD3 PICTURE TM(nAcD3,16)
		@Li ,204 PSAY nAcD6 PICTURE TM(nAcD6,16)
		Li+=2
		nAcD1 := 0
		nAcD2 := 0
		nAcD3 := 0
		nAcD4 := 0
		nAcD5 := 0
		nAcD6 := 0
		nAcD7 := 0
	Endif

End // Documento, Serie
If nACG1 <> 0 .Or. nACG2 <> 0 .Or. nACG5 <> 0 .Or. nACG4 <> 0 .Or. nACG7 <> 0 .Or. nACG3 <> 0 .Or. nACG6 <> 0 
	IF li >= 52
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf
	
	
	@Li ,  0 PSAY STR0016	//"TOTAL GERAL            ---->"
	@Li , 46 PSAY nAcG1 PICTURE PESQPICTQT("D2_QUANT",16)
	@Li , 80 PSAY nAcG2 PICTURE TM(nAcG2,16)
	@Li ,123 PSAY nAcG5	PICTURE TM(nAcG5,16)
	@Li ,141 PSAY nAcG4	PICTURE TM(nAcG4,16)
	@Li ,158 PSAY nAcG7	PICTURE TM(nAcG7,16)
	@Li ,184 PSAY nAcG3	PICTURE TM(nAcG3,16)
	@Li ,204 PSAY nAcG6	PICTURE TM(nAcG6,16)
	Li++
	roda(cbcont,cbtxt,tamanho)
EndIf
If lQuery
	DbSelectArea(cAliasSF2)
	DbCloseArea()
Else
	//��������������������������������������������������������������Ŀ
	//� Devolve condicao original ao SF2 e apaga arquivo de trabalho.�
	//����������������������������������������������������������������
	RetIndex("SF2")
	dbSelectArea("SF2")
	dbClearFilter()
	dbSetOrder(1)

	cIndex += OrdBagExt()
	If File(cIndex)
		Ferase(cIndex)
	Endif
Endif

dbSelectArea("SD2")
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return .T.



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C550ImpInt� Autor � Bruno Sobieski        � Data � 13.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C550ImpInt(lEnd,WnRel,cString)

Local nCt 		:= 0
Local lContinua := .T., dEmisAnt
#IFDEF TOP
	Local cQuery	:= ""
#ELSE
	Local cCondicao
#ENDIF
Local nTotNetoNota :=0
Local nTotNetoGeral:=0
Local nTotNetoDia  :=0
Local lNovoDia 	:= .F.
Local dDia
Local lQuery	:= .F.
Local lValadi	:= .F.
Local cAdiant	:= ""

Private tamanho	:= "G"
Private limite 	:= 220
Private cabec1,cabec2,cabec3

Private nAcN1  := 0, nAcN2 := 0, nAcN3 := 0
Private nAcG1  := 0, nAcG2 := 0, nAcG3 := 0
Private nAcD1  := 0, nAcD2 := 0, nAcD3 := 0
Private aImpostos:={}
Private nAcImpInc  :=0,nAcDImpInc    :=0,nAcGimpInc    :=0
Private nAcImpNoInc:=0,nAcDImpNoInc  :=0,nAcGimpNoInc  :=0

Private nDecs:=MsDecimais(mv_par16)

Private cAliasSF2 := ""
Private cAliasSF1 := ""
Private cAliasSD1 := ""
Private cAliasSD2 := ""
Private cAliasPrt := ""

Private	cDocFil  := ""
Private	cNota    := ""
Private cSerieNF := ""
Private cCliente := ""
Private nFrete   := 0
Private nFretAut := 0
Private nSeguro  := 0
Private nDespesa := 0
Private	nMoeda   := 0
Private	nTxMoeda := 0
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Imporessao do Cabecalho e Rodape   �
//����������������������������������������������������������������
cbtxt    := Space(10)
cbcont   := 00
li       := 80
m_pag    := 01
imprime  := .T.

//��������������������������������������������������������������Ŀ
//� Monta o Cabecalho de acordo com o tipo de emissao            �
//����������������������������������������������������������������
titulo	:= STR0005	//"RELACAO DAS NOTAS FISCAIS  "
Cabec1	:= STR0018 //"PRODUCTO         DESCRIPCI�N                      DEP. PEDIDO/IT  REMITO/ITEM        CANTIDAD    VALOR UNITARIO  VALOR MERCADERIA     GRAVAMENES NO        GRAVAMENES      OTROS GASTOS               TOTAL"

//                     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                               1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19
Cabec2	:= STR0019 //
//��������������������������������������������������������������Ŀ
//� Cria Indice de Trabalho                                      �
//����������������������������������������������������������������
#IFDEF TOP
	If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
		lValadi	:= .T.
		cAdiant	:= Trim(RetTitle("D2_VALADI"))		
		Cabec2		:= Substr(Cabec2,1,113)+cAdiant+Substr(Cabec2,114+Len(cAdiant))				
	EndIf
	
    If TcSrvType()<>"AS/400"
	    lQuery := .T.
		cAliasSF2 := GetNextAlias()
		cAliasSD2 := cAliasSF2
		cQuery:="SELECT F2_FILIAL, F2_CLIENTE,F2_LOJA,F2_DOC,F2_SERIE,F2_EMISSAO"
		cQuery+=",F2_MOEDA,F2_TXMOEDA,F2_TIPO,F2_ESPECIE"
		cQuery+=",F2_FRETE,F2_FRETAUT,F2_SEGURO,F2_DESPESA,F2_VALBRUT,SF2.R_E_C_N_O_ SF2RECNO "
		cQuery+=",SA1.A1_NOME "	
		cSCpo:="1"
		cCpo:="D2_VALIMP"+cSCpo
		While SD2->(FieldPos(cCpo))>0
			cQuery+=","+cCpo
			cSCpo:=Soma1(cSCpo)
			cCpo:="D2_VALIMP"+cSCpo
		Enddo
		cQuery+=",D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,D2_GRADE,D2_COD,D2_QUANT,D2_CF,D2_TES,D2_LOCAL,D2_ITEMPV,D2_PEDIDO,D2_REMITO,D2_ITEMREM,D2_PRCVEN,D2_TOTAL"+Iif(lValadi,"-D2_VALADI D2_TOTAL, D2_VALADI","")+" "
		cQuery+="FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SD2")+" SD2, "+RetSqlName("SA1")+" SA1 WHERE "
		//cQuery+="F2_FILIAL='"+xFilial("SF2")+"'"
//		cQuery+=" AND F2_DOC>='"+mv_par01+"' AND F2_DOC<='"+mv_par02+"'"
		cQuery+=" F2_DOC>='"+mv_par01+"' AND F2_DOC<='"+mv_par02+"'"
		cQuery+=" AND F2_EMISSAO>='"+DTOS(mv_par03)+"' AND F2_EMISSAO<='"+DTOS(mv_par04)+"'"
		cQuery+=" AND F2_SERIE>='"+mv_par07+"' AND F2_SERIE<='"+mv_par08+"'"
		cQuery+=" AND F2_TIPO<>'D'"
		cQuery+=" AND F2_CLIENTE>='"+mv_par19+"' AND F2_CLIENTE<='"+mv_par20+"'"
		cQuery+=" AND NOT ("+IsRemito(2,"F2_TIPODOC")+")"
		if mv_par17==2   //nao imprimir notas com moeda diferente da escolhida
			cQuery+=" AND F2_MOEDA=" + Alltrim(str(mv_par16))
		endif
		cQuery+=" AND SF2.D_E_L_E_T_<>'*' "
		cQuery+=" AND SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=F2_CLIENTE AND SA1.A1_LOJA=F2_LOJA "
		cQuery+=" AND SA1.D_E_L_E_T_=' ' "
		cQuery+=" AND D2_FILIAL=F2_FILIAL AND D2_CLIENTE=F2_CLIENTE AND D2_LOJA=F2_LOJA "
		cQuery+=" AND D2_DOC=F2_DOC AND D2_SERIE=F2_SERIE "
		cQuery+=" AND D2_COD>='"+mv_par05+"' AND D2_COD<='"+mv_par06+"' "
		cQuery+=" AND D2_GRUPO>='"+mv_par11+"' AND D2_GRUPO<='"+mv_par12+"' "
		cQuery+=" AND D2_TP>='"+mv_par13+"' AND D2_TP<='"+mv_par14+"' "
		cQuery+=" AND SD2.D_E_L_E_T_=' ' "
		
		cQuery+=" ORDER BY F2_FILIAL, F2_EMISSAO,F2_DOC,F2_SERIE,D2_COD,D2_ITEM"
		cQuery:=ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSF2,.F.,.T.)
		TCSetField(cAliasSF2,"F2_EMISSAO","D",8,0)
	Else
#ENDIF
		cAliasSF2 := "SF2"
		cAliasSD2 := "SD2"
		dbSelectArea("SF2")
		cIndex	:= CriaTrab("",.F.)
		cKey 	:= 'F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE'
	
//		cCondicao := 'F2_FILIAL=="'+xFilial("SF2")+'".And.F2_DOC>="'+mv_par01+'"'
		cCondicao := 'F2_DOC>="'+mv_par01+'"'
		cCondicao += '.And.F2_DOC<="'+mv_par02+'".And.DTOS(F2_EMISSAO)>="'+DTOS(mv_par03)+'"'
		cCondicao += '.And.DTOS(F2_EMISSAO)<="'+DTOS(mv_par04)+'".And. F2_SERIE>="'+mv_par07
		cCondicao += '".And.F2_SERIE<= "'+mv_par08+'".And.F2_TIPO <> "D"'
		cCondicao += '.And.F2_CLIENTE>="'+mv_par19+'".And.F2_CLIENTE<="'+mv_par20+'"'
		cCondicao += '.And. !('+IsRemito(2,'SF2->F2_TIPODOC')+')'		
	
		if mv_par17==2   //nao imprimir notas com moeda diferente da escolhida
			cCondicao+=" .And. F2_MOEDA==" + Alltrim(str(mv_par16))
		endif
	
		IndRegua("SF2",cIndex,cKey,,cCondicao)
		nIndex := RetIndex("SF2")
		dbSelectArea("SF2")
		#IFNDEF TOP
			dbSetIndex(cIndex+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGoTop()
#IFDEF TOP
	Endif    
#ENDIF

#IFDEF TOP
    If TcSrvType()<>"AS/400"
	    lQuery := .T.
		cAliasSF1 := GetNextAlias()
		cAliasSD1 := cAliasSF1
		cQuery:="SELECT F1_FILIAL, F1_FORNECE,F1_LOJA,F1_DOC,F1_SERIE,F1_DTDIGIT"
		cQuery+=",F1_MOEDA,F1_TXMOEDA,F1_TIPO,F1_ESPECIE"
		cQuery+=",F1_FRETE,F1_SEGURO,F1_DESPESA"
		cQuery+=",SA1.A1_NOME "
		cSCpo:="1"
		cCpo:="D1_VALIMP"+cSCpo
		While SD1->(FieldPos(cCpo))>0
			cQuery+=","+cCpo
			cSCpo:=Soma1(cSCpo)
			cCpo:="D1_VALIMP"+cSCpo
		Enddo
		cQuery+=",D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_TIPO,D1_COD,D1_QUANT,D1_CF,D1_TES,D1_LOCAL,D1_ITEMPV,D1_NUMPV,D1_REMITO,D1_ITEMREM,D1_VUNIT,D1_TOTAL,D1_VALDESC "
		cQuery+="FROM "+RetSqlName("SF1")+" "+cAliasSF1+", "+RetSqlName("SD1")+" SD1, "+RetSqlName("SA1")+" SA1 WHERE "
//		cQuery+="F1_FILIAL='"+xFilial("SF1")+"'"
//		cQuery+=" AND F1_DOC>='"+mv_par01+"' AND F1_DOC<='"+mv_par02+"'"
		cQuery+=" F1_DOC>='"+mv_par01+"' AND F1_DOC<='"+mv_par02+"'"
		cQuery+=" AND F1_DTDIGIT>='"+DTOS(mv_par03)+"' AND F1_DTDIGIT<='"+DTOS(mv_par04)+"'"
		cQuery+=" AND F1_SERIE>='"+mv_par07+"' AND F1_SERIE<='"+mv_par08+"'"
		cQuery+=" AND F1_TIPO='D'"
		cQuery+=" AND F1_FORNECE>='"+mv_par19+"' AND F1_FORNECE<='"+mv_par20+"'"
		cQuery+=" AND NOT ("+IsRemito(2,"F1_TIPODOC")+")"
		if mv_par17==2   //nao imprimir notas com moeda diferente da escolhida
			cQuery+=" AND F1_MOEDA=" + AllTrim(str(mv_par16))
		endif
		cQuery+=" AND "+cAliasSF1+".D_E_L_E_T_<>'*' "
		cQuery+=" AND SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=F1_FORNECE AND SA1.A1_LOJA=F1_LOJA "
		cQuery+=" AND SA1.D_E_L_E_T_=' ' "
//		cQuery+=" AND D1_FILIAL='"+xFilial("SD1")+"' AND D1_FORNECE=F1_FORNECE AND D1_LOJA=F1_LOJA "
		cQuery+=" AND D1_FILIAL=F1_FILIAL AND D1_FORNECE=F1_FORNECE AND D1_LOJA=F1_LOJA "
		cQuery+=" AND D1_DOC=F1_DOC AND D1_SERIE=F1_SERIE "
		cQuery+=" AND D1_COD>='"+mv_par05+"' AND D1_COD<='"+mv_par06+"' "
		cQuery+=" AND D1_GRUPO>='"+mv_par11+"' AND D1_GRUPO<='"+mv_par12+"' "
		cQuery+=" AND D1_TP>='"+mv_par13+"' AND D1_TP<='"+mv_par14+"' "
		cQuery+=" AND SD1.D_E_L_E_T_=' ' "
		cQuery+=" ORDER BY F1_FILIAL, F1_DTDIGIT,F1_DOC,F1_SERIE,D1_COD,D1_ITEM "
		cQuery:=ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSF1,.F.,.T.)
		TCSetField(cAliasSF1,"F1_DTDIGIT","D",8,0)
	Else
#ENDIF
		cAliasSF1 := "SF1"
		cAliasSD1 := "SD1"
		dbSelectArea("SF1")
		cIndex1  := CriaTrab("",.F.)
		cKey     := 'F1_FILIAL+DTOS(F1_DTDIGIT)+F1_DOC+F1_SERIE'
	
//		cCondicao := 'F1_FILIAL=="'+xFilial("SF1")+'".And.F1_DOC>="'+mv_par01+'"'
		cCondicao := 'F1_DOC>="'+mv_par01+'"'
		cCondicao += '.And.F1_DOC<="'+mv_par02+'".And.DTOS(F1_DTDIGIT)>="'+DTOS(mv_par03)+'"'
		cCondicao += '.And.DTOS(F1_DTDIGIT)<="'+DTOS(mv_par04)+'".And. F1_SERIE>="'+mv_par07
		cCondicao += '".And.F1_SERIE<= "'+mv_par08+'".And.F1_TIPO == "D"'
		cCondicao += '.And.F1_FORNECE>="'+mv_par19+'".And.F1_FORNECE<="'+mv_par20+'"'
		cCondicao += '.And. !('+IsRemito(2,'SF1->F1_TIPODOC')+')'		
	
		if mv_par17==2  //nao imprimir notas com moeda diferente da escolhida
			cCondicao+=" .And. F1_MOEDA==" + AllTrim(str(mv_par16))
		endif
	
		IndRegua("SF1",cIndex1,cKey,,cCondicao)
		nIndex := RetIndex("SF1")
		dbSelectArea("SF1")
		#IFNDEF TOP
			dbSetIndex(cIndex1+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGoTop()
#IFDEF TOP
	Endif    
#ENDIF

dbSelectArea(cAliasSF2)

SetRegua(RecCount())    // Total de Elementos da regua
While (!(cAliasSF1)->(Eof()) .Or. !(cAliasSF2)->(Eof()) ).And. lContinua

	IF lEnd
		@Prow()+1,001 PSAY STR0007		//"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	Endif

	IncRegua()
	
	If !Empty(aReturn[7])
		If lQuery
			SF2->(MsGoto((cAliasSF2)->SF2RECNO))
		Endif
		If !SF2->(&(aReturn[7]))
			dbSkip()
			Loop			
	    EndIf
	EndIf
	
	nCt := 1

	If !(cAliasSF1)->(eof()) .And. If(!(cAliasSF2)->(EOF()),(cAliasSF2)->F2_EMISSAO > (cAliasSF1)->F1_DTDIGIT,.T.)
		If !lQuery
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial()+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek((cAliasSF1)->F1_FILIAL+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
		Endif
		cAliasPrt   := cAliasSF1
		dEmisAnt    := (cAliasSF1)->F1_DTDIGIT
		cNota		:= (cAliasSF1)->F1_DOC
		cSerieNF	:= (cAliasSF1)->F1_SERIE
		cCliente	:= (cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA
		nFrete		:= (cAliasSF1)->F1_FRETE
		nSeguro		:= (cAliasSF1)->F1_SEGURO
		nDespesa	:= (cAliasSF1)->F1_DESPESA
		nMoeda		:= (cAliasSF1)->F1_MOEDA
		nTxMoeda	:= (cAliasSF1)->F1_TXMOEDA
		DbSelectArea(cAliasSD1)
		PrintSD1(@nCt,lQuery)
	ElseIf  !(cAliasSF2)->(Eof())
		If !lQuery
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial()+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
			dbSelectArea("SD2")
			dbSetOrder(3)
			dbSeek((cAliasSF2)->F2_FILIAL+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
		Endif
		cAliasPrt   := cAliasSF2
		dEmisAnt    := (cAliasSF2)->F2_EMISSAO
		cDocFil		:= (cAliasSF2)->F2_DOC
		cNota		:= (cAliasSF2)->F2_DOC
		cSerieNF	:= (cAliasSF2)->F2_SERIE
		cCliente	:= (cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA
		nFrete		:= (cAliasSF2)->F2_FRETE
		nFretAut    := (cAliasSF2)->F2_FRETAUT
		nSeguro		:= (cAliasSF2)->F2_SEGURO
		nDespesa	:= (cAliasSF2)->F2_DESPESA
		nMoeda		:= (cAliasSF2)->F2_MOEDA
		nTxMoeda	:= (cAliasSF2)->F2_TXMOEDA
		DbSelectArea(cAliasSD2)
		PrintSD2(@nCt,lQuery)
	Endif

	If nAcN2 > 0
		nAcN3 := xmoeda(nFrete+nSeguro+nDespesa,nMoeda,mv_par16,dEmisAnt,nDecs+1,nTXMoeda)
		If nAcN3 != 0 .Or. nFretAut != 0
			@Li ,  0 PSAY STR0013	//"DESPESAS ACESSORIAS -------> "
			@Li ,176 PSAY nAcN3+nFretAut PICTURE TM(nAcN3,17,nDecs)
			Li++
		EndIf

		@Li , 0 PSAY STR0014+cNota+" / "+cSerieNF+" ---->"      //"TOTAL DA NOTA - "
        @Li,090 PSAY nAcN1          PICTURE PESQPICT("SD2","D2_QUANT",11,mv_par16)
		@Li,122 PSAY nAcN2 			PICTURE tm(nAcN2		,16,nDecs)
		@Li,141 PSAY nAcImpInc 		PICTURE tm(nAcImpInc	,16, nDecs)
		@Li,159 PSAY nAcImpNoInc 	PICTURE tm(nAcImpNoInc	,16, nDecs)
		@Li,176 PSAY nAcN3+nFretAut PICTURE TM(nAcN3		,17,nDecs)

		Li++

		nTotNetoNota:=nAcN2+nAcN3+nAcImpInc

        @Li , 21 PSAY STR0017 //"Total Neto Factura ---->"
		//      @Li , 54 PSAY xMoeda(nTotNetoNota,1,MV_PAR16,IIf(cAliasPrt=="SF2",SD2->D2_EMISSAO,SD1->D1_DTDIGIT)) PICTURE TM(nTotNetoDia,16)
        @Li , 53 PSAY nTotNetoNota PICTURE TM(nTotNetoDia,16,nDecs)
		Li++
		@Li ,  0 PSAY __PrtThinLine()
		Li++

		If cAliasPrt   == cAliasSF2
			nAcGImpInc  += nAcImpInc
			nAcGImpNoInc+= nAcImpNoInc
			nAcG1 += nAcN1
			nAcG2 += nAcN2
			nAcG3 += nAcN3+nFretAut
		Else
			nAcGImpInc  -= nAcImpInc
			nAcGImpNoInc-= nAcImpNoInc
			nAcG1 -= nAcN1
			nAcG2 -= nAcN2
			nAcG3 -= nAcN3+nFretAut
		Endif
	EndIf

	nAcDImpInc  += nAcImpInc
	nAcDImpNoInc+= nAcImpNoInc

	nAcD1 += nAcN1
	nAcD2 += nAcN2
	nAcD3 += nAcN3+nFretAut

	nAcImpInc   := 0
	nAcImpNoInc := 0

	nAcn1 := 0
	nAcn2 := 0
	nAcn3 := 0

	dbSelectArea(cAliasPrt)
	If !lQuery
		dbSkip()
	Endif
	If cAliasPrt   == cAliasSF1
		lNovoDia := ( nAcd1 > 0 .And. ( dEmisAnt != F1_DTDIGIT .Or. Eof() ))
		dDia     := (cAliasPrt)->F1_DTDIGIT
	Else
		lNovoDia := ( nAcd1 > 0 .And. ( dEmisAnt != F2_EMISSAO .Or. Eof() ))
		dDia     := (cAliasPrt)->F2_EMISSAO
	Endif

	If lNovoDia
		@Li ,  0 PSAY STR0015+dtoc(dEmisAnt)		//"TOTAL DO DIA  ----> "
        @Li ,090 PSAY nAcD1             PICTURE PESQPICT("SD2","D2_QUANT",11,mv_par16)
		@Li ,122 PSAY nAcD2 			PICTURE TM(nAcD2		,16,nDecs)
		@Li ,141 PSAY nAcDimpInc 		PICTURE TM(nAcDImpInc	,16,nDecs)
		@Li ,159 PSAY nAcDimpNoInc 		PICTURE TM(nAcDImpNoInc	,16,nDecs)
		@Li ,176 PSAY nAcD3 			PICTURE TM(nAcD3		,17,nDecs)

		Li++
		nTotNetoDia:=nAcD2+nAcD3+nAcDImpInc

        @Li , 21 PSAY STR0020 //"Total Neto Dia      ---->"
		//@Li , 54 PSAY xMoeda(nTotNetoDia,1,MV_PAR16,dDia)  PICTURE TM(nTotNetoDia,16,nDecs)
        @Li , 53 PSAY nTotNetoDia  PICTURE TM(nTotNetoDia,16,nDecs)
		Li+=3

		nAcDImpInc  := 0
		nAcDImpNoInc:= 0
		nAcD1 := 0
		nAcD2 := 0
		nAcD3 := 0

	Endif

End // Documento, Serie

If nAcG1 <> 0 .Or. nAcG2 <> 0 .Or. nAcG3 <> 0 
	IF li >= 52
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf

	Li++
	@Li ,  0 PSAY STR0016	//"TOTAL GERAL            ---->"
	@Li ,090 PSAY nAcG1 PICTURE PESQPICT("SD2","D2_QUANT",11,mv_par16)
	@Li ,122 PSAY nAcG2 PICTURE TM(nAcG2,16,nDecs)
	@Li ,176 PSAY nAcG3 PICTURE TM(nAcG3,17,nDecs)
	Li++
	
	nTotNetoGeral:=nAcG2+nAcG3+nAcGImpInc
	
	@Li , 21 PSAY STR0021 //"Total Neto General ---->"
	@Li , 52 PSAY nTotNetoGeral PICTURE TM(nTotNetoGeral,18,nDecs)
	Li++
	roda(cbcont,cbtxt,tamanho)
Endif
      
//��������������������������������������������������������������Ŀ
//� Devolve condicao original ao SF2 e apaga arquivo de trabalho.�
//����������������������������������������������������������������
If lQuery
	DbSelectArea(cAliasSF2)
	DbCloseArea()
	DbSelectArea(cAliasSF1)
	DbCloseArea()
Else
	RetIndex("SF2")
	dbSelectArea("SF2")
	dbClearFilter()
	dbSetOrder(1)

	RetIndex("SF1")
	dbSelectArea("SF1")
	dbClearFilter()
	dbSetOrder(1)

	cIndex += OrdBagExt()
	If File(cIndex)
		Ferase(cIndex)
	Endif
	cIndex1 += OrdBagExt()
	If File(cIndex1)
		Ferase(cIndex1)
	Endif
Endif

dbSelectArea("SD2")
dbSetOrder(1)

dbSelectArea("SD1")
dbSetOrder(1)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PrintSD2 � Autor � Bruno Sobieski Chavez � Data � 28.04.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime itens do SD2 (Localizacoes).                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC Function PRINTSD2(nCt,lQuery)
Local nTotImpInc  := 0
Local nTotImpNoInc:= 0
Local nImpInc:=0,nImpNoInc:=0
Local cLocal   :=""
Local cItemPv  :=""
Local cNumPed  :=""
Local nPrcVen  :=0
Local nY       :=0 
Local cMascara :=GetMv("MV_MASCGRD")
Local nTamRef  :=Val(Substr(cMascara,1,2))
Local nTamLin  :=Val(Substr(cMascara,4,2))
Local nTamCol  :=Val(Substr(cMascara,7,2))
Local cNumRem, cItemRem
Local nReg := 0


While !Eof() .and. D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == cDocFil+cNota+cSerieNF+cCliente
	If !lQuery
		If D2_COD < mv_par05 .Or. D2_COD > mv_par06 .Or. D2_GRUPO < mv_par11 .Or. ;
				D2_GRUPO > mv_par12 .Or. D2_TP < mv_par13 .Or. D2_TP > mv_par14 .Or. ;
				D2_SERIE < mv_par07 .Or. D2_SERIE > mv_par08 .Or. TRIM(D2_ESPECIE) <> TRIM(SF2->F2_ESPECIE)
			dbSkip()
			Loop
		Endif
	Endif
	//���������������������������������������������Ŀ
	//� Valida o produto conforme a mascara         �
	//�����������������������������������������������
	lRet:=ValidMasc(SD2->D2_COD,MV_PAR09)

	If !lRet
		dbSkip()
		Loop
	Endif

	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf

	If nCt == 1
		If lQuery
        	@Li ,   0 PSAY STR0011+(cAliasSF2)->F2_CLIENTE+" "+(cAliasSF2)->F2_LOJA+" - "+(cAliasSF2)->A1_NOME+" "+STR0009+DTOC((cAliasSF2)->F2_EMISSAO)+STR0010+If((cAliasSD2)->D2_TIPO=="C",STR0023,STR0024)  //"CLIENTE    : "###"EMISSAO : "###" TIPO DA NOTA : "###"Devolucion"###"Debito"###"Factura"
		Else
	        @Li ,   0 PSAY STR0011+SA1->A1_COD+" "+SA1->A1_LOJA+" - "+SA1->A1_NOME+" "+STR0009+DTOC((cAliasSF2)->F2_EMISSAO)+STR0010+If(D2_TIPO=="C",STR0023,STR0024)  //"CLIENTE    : "###"EMISSAO : "###" TIPO DA NOTA : "###"Devolucion"###"Debito"###"Factura"
		Endif
		nCt++
		Li++
		dbSelectArea(cAliasSD2)
	EndIf

    If MV_PAR21==1
		@Li , 0 PSAY IIF(D2_GRADE == "S".And. MV_PAR10 == 1,Substr(D2_COD,1,nTamRef),D2_COD)
		//���������������������������������������������Ŀ
		//� Utiliza Descricao conforme mv_par15         �
		//�����������������������������������������������
		IF mv_par15 == 1
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
	        @li , 16 PSAY Substr(B1_DESC,1,30)
		Else
			dbSelectArea("SA7");dbSetOrder(2)
			If dbSeek(xFilial()+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
	            @li , 16 PSAY Substr(A7_DESCCLI,1,30)
			Else
				dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD2)->D2_COD)
	            @li , 16 PSAY Substr(B1_DESC,1,30)
			Endif
		Endif
	Endif

	dbSelectArea(cAliasSD2)
	cCf         := D2_CF
	cTes        := D2_TES
	cLocal      := D2_LOCAL
	cItemPv     := D2_ITEMPV
	cNumPed     := D2_PEDIDO
	cNumRem     := D2_REMITO
	cItemRem    := D2_ITEMREM
	nTotQuant   := 0
	nTotal      := 0
	nTotImpInc  := 0
	nTotImpNoInc:= 0
	nPrcVen     := xmoeda(D2_PRCVEN,(cAliasSF2)->F2_MOEDA,mv_par16,,nDecs+1,(cAliasSF2)->F2_TXMOEDA)

	nReg := 0
	If (cAliasSD2)->D2_GRADE == "S" .And. MV_PAR10 == 1
		cProdRef:= Substr((cAliasSD2)->D2_COD,1,nTamRef)
		While !Eof() .And. cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef) ;
				.And. (cAliasSD2)->D2_GRADE == "S" .And. cNumPed == (cAliasSD2)->D2_PEDIDO
			nTotQuant+= (cAliasSD2)->D2_QUANT
			nTotal   += IIF(!((cAliasSF2)->F2_TIPO $ "IP"),xmoeda(D2_TOTAL,(cAliasSF2)->F2_MOEDA,mv_par16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA),0)

			If (cAliasSF2)->F2_TIPO == "I"
				nCompIcm+=xmoeda(D2_TOTAL,(cAliasSF2)->F2_MOEDA,mv_par16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
			EndIf

			nImpInc  := 0
			nImpNoInc:= 0

			aImpostos:=TesImpInf((cAliasSD2)->D2_TES)

			For nY:=1 to Len(aImpostos)
				cCampImp:=cAliasSD2+"->"+(aImpostos[nY][2])
				If ( aImpostos[nY][3]=="1" )
					nImpInc     += xmoeda(&cCampImp,(cAliasSF2)->F2_MOEDA,mv_par16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
				Else
					nImpNoInc   += xmoeda(&cCampImp,(cAliasSF2)->F2_MOEDA,mv_par16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
				EndIf
			Next

			nTotImpInc     += nImpInc
			nTotImpNoInc   += nImpNoInc

			nReg     := Recno()

			dbSkip()

			If !lQuery
				If SD2->D2_COD < mv_par05 .Or. SD2->D2_COD > mv_par06 .Or.;
						SD2->D2_GRUPO < mv_par11 .Or. SD2->D2_GRUPO > mv_par12
					dbSkip()
					Loop
				Endif
			Endif
			//�������������������������������������������Ŀ
			//� Valida o produto conforme a mascara       �
			//���������������������������������������������
			lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR09)
			If !lRet
				dbSkip()
				Loop
			Endif
		End

		If !lQuery
			If nReg > 0
				dbGoto(nReg)
				nReg:=0
			Endif
		Endif
		If MV_PAR21==1
    	    @Li ,049 PSAY cLocal
	        @Li ,054 PSAY cNumPed
	        @Li ,061 PSAY cItemPV
	        @Li ,065 PSAY cNumRem
	        @Li ,087 PSAY cItemRem
	        @Li ,090 PSAY nTotQuant             PICTURE PESQPICT("SD2","D2_QUANT"   ,11,mv_par16)
	        @Li ,103 PSAY nPrcVen               PICTURE PESQPICT("SD2","D2_PRCVEN"  ,16,mv_par16)        
			@Li ,122 PSAY nTotal         		PICTURE TM((D2_TOTAL)	,16,nDecs)
			@Li ,141 PSAY nTotImpInc     		PICTURE TM(nTotImpNoInc	,16,nDecs)
			@Li ,159 PSAY nTotImpNoInc   		PICTURE TM(nTotImpInc  	,16,ndecs)
			@Li ,196 PSAY (nTotal+nTotImpInc) 	PICTURE TM(nTOTAL		,18,nDecs)
		Endif

		nAcN1       += nTotQuant
		nAcN2       += nTotal
		nAcImpInc   += nTotImpInc
		nAcImpNoInc += nTotImpNoInc

	Else
		nImpInc  := 0
		nImpNoInc:= 0

		aImpostos:=TesImpInf((cAliasSD2)->D2_TES)

		For nY:=1 to Len(aImpostos)
			cCampImp:=cAliasSD2+"->"+(aImpostos[nY][2])
			If ( aImpostos[nY][3]=="1" )
				nImpInc     += xmoeda(&cCampImp,(cAliasSF2)->F2_MOEDA,mv_par16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
			Else
				nImpNoInc   += xmoeda(&cCampImp,(cAliasSF2)->F2_MOEDA,mv_par16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)
			EndIf
		Next

		If MV_PAR21==1
	        @Li ,049 PSAY D2_LOCAL
	        @Li ,054 PSAY D2_PEDIDO
	        @Li ,061 PSAY D2_ITEMPV
	        @Li ,065 PSAY D2_REMITO
	        @Li ,087 PSAY D2_ITEMREM
	        @Li ,090 PSAY D2_QUANT       PICTURE PESQPICT("SD2","D2_QUANT",11,mv_par16)
	        @Li ,103 PSAY xMoeda(D2_PRCVEN  ,(cAliasSF2)->F2_MOEDA,MV_PAR16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA) PICTURE PESQPICT("SD2","D2_PRCVEN",16,mv_par16)
			@Li ,122 PSAY xMoeda(D2_TOTAL	,(cAliasSF2)->F2_MOEDA,MV_PAR16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA) PICTURE TM((D2_TOTAL),16,nDecs)
			@Li ,141 PSAY nImpInc 		PICTURE TM(nImpNoInc	, 16,nDecs)
			@Li ,159 PSAY nImpNoInc 	PICTURE TM(nImpInc		, 16,nDecs)
			@Li ,196 PSAY nImpInc+xMoeda(D2_TOTAL,(cAliasSF2)->F2_MOEDA,mv_par16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA) PICTURE TM(D2_TOTAL,18,nDecs)
		Endif

		nAcImpInc   += nImpInc
		nAcImpNoInc += nImpNoInc

		nAcN1  += D2_QUANT
		nAcN2  += xmoeda(D2_TOTAL,(cAliasSF2)->F2_MOEDA,mv_par16,(cAliasSF2)->F2_EMISSAO,nDecs+1,(cAliasSF2)->F2_TXMOEDA)

	Endif
	
    If MV_PAR21==1 .AND. cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
       	//Imprime adiantamento
       	Li++
       	@Li ,103 PSAY D2_VALADI PICTURE PESQPICT("SD2","D2_PRCVEN"  ,16,mv_par16)
    EndIf		
	
	If MV_PAR21==1
		Li++
	Endif
	If nReg==0
		dbSkip()
	Endif
End // Nota
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PrintSD1 � Autor � Bruno Sobieski Chavez � Data � 28.04.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime itens do SD1 (Localizacoes).                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR550			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC Function PRINTSD1(nCt,lQuery)
Local nImpInc:=0,nImpNoInc:=0,nY:=0

While !Eof() .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == cDocFil+cNota+cSerieNF+cCliente
	If !lQuery
		If D1_COD < mv_par05 .Or. D1_COD > mv_par06 .Or. D1_GRUPO < mv_par11 .Or. ;
			D1_GRUPO > mv_par12 .Or. D1_TP < mv_par13 .Or. D1_TP > mv_par14 .Or. ;
			D1_SERIE < mv_par07 .Or. D1_SERIE > mv_par08 .Or. TRIM(D1_ESPECIE) <> TRIM(SF1->F1_ESPECIE)
		//      D1_SERIE < mv_par07 .Or. D1_SERIE > mv_par08 .Or. TRIM(D1_ESPECIE) <> TRIM(SF2->F2_ESPECIE)
			dbSkip()
			Loop
		Endif
	Endif
	//���������������������������������������������Ŀ
	//� Valida o produto conforme a mascara         �
	//�����������������������������������������������
	lRet:=ValidMasc((cAliasSD1)->D1_COD,MV_PAR09)

	If !lRet
		dbSkip()
		Loop
	Endif

	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf

	If nCt == 1
		If lQuery
			@Li ,   0 PSAY STR0011+(cAliasSF1)->F1_FORNECE+" "+(cAliasSF1)->F1_LOJA+" - "+(cAliasSf1)->A1_NOME+"  "+STR0009+DTOC((cAliasSF1)->F1_DTDIGIT)+STR0010+STR0022   //"CLIENTE    : "###"EMISSAO : "###" TIPO DA NOTA : "
		Else
			@Li ,   0 PSAY STR0011+SA1->A1_COD+" "+SA1->A1_LOJA+" - "+SA1->A1_NOME+"  "+STR0009+DTOC((cAliasSF1)->F1_DTDIGIT)+STR0010+STR0022   //"CLIENTE    : "###"EMISSAO : "###" TIPO DA NOTA : "
		Endif

		nCt++
		Li++
		dbSelectArea(cAliasSD1)
	EndIf

	If MV_PAR21==1
		@Li , 0 PSAY D1_COD
		//���������������������������������������������Ŀ
		//� Utiliza Descricao conforme mv_par15         �
		//�����������������������������������������������
		IF mv_par15 == 1
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD1)->D1_COD)
	        @li , 16 PSAY Substr(B1_DESC,1,30)
		Else
			dbSelectArea("SA7");dbSetOrder(2)
			If dbSeek(xFilial()+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
	            @li , 16 PSAY Substr(A7_DESCCLI,1,30)
			Else
				dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+(cAliasSD1)->D1_COD)
	            @li , 16 PSAY Substr(B1_DESC,1,30)
			Endif
		Endif
	Endif

	dbSelectArea(cAliasSD1)

	nTotQuant   := 0
	nTotal      := 0
	nImpInc  := 0
	nImpNoInc:= 0

	aImpostos:=TesImpInf((cAliasSD1)->D1_TES)

	For nY:=1 to Len(aImpostos)
		cCampImp:=cAliasSD1+"->"+(aImpostos[nY][2])
		If ( aImpostos[nY][3]=="1" )
			nImpInc   += xmoeda(&cCampImp,(cAliasSF1)->F1_MOEDA,mv_par16,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
		Else
			nImpNoInc += xmoeda(&cCampImp,(cAliasSF1)->F1_MOEDA,mv_par16,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
		EndIf
	Next

    If MV_PAR21==1
    	@Li ,049 PSAY D1_LOCAL
	    @Li ,054 PSAY D1_NUMPV
	    @Li ,061 PSAY D1_ITEMPV
	    @Li ,065 PSAY D1_REMITO
	    @Li ,087 PSAY D1_ITEMREM
	    @Li ,090 PSAY D1_QUANT  PICTURE PESQPICT("SD1","D1_QUANT",11,mv_par16)
    
	    // Calcula Valor Unitario e Total considerando o Desconto - Camurca
    
    	@Li ,103 PSAY xMoeda((D1_VUNIT - (D1_VALDESC/D1_QUANT)) ,(cAliasSF1)->F1_MOEDA,mv_par16,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA) PICTURE PESQPICT("SD1","D1_VUNIT",16,mv_par16)
		@Li ,122 PSAY xMoeda((D1_TOTAL - D1_VALDESC),(cAliasSF1)->F1_MOEDA,mv_par16,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA) PICTURE TM((D1_TOTAL),16,nDecs)
		
		@Li ,141 PSAY nImpInc   PICTURE TM(nImpNoInc,16,nDecs)
		@Li ,159 PSAY nImpNoInc PICTURE TM(nImpInc  ,16,nDecs)
		@Li ,196 PSAY nImpInc+xmoeda((D1_TOTAL - D1_VALDESC),(cAliasSF1)->F1_MOEDA,mv_par16,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA) PICTURE TM(D1_TOTAL ,18,nDecs)
	Endif

	nAcImpInc   += nImpInc
	nAcImpNoInc += nImpNoInc

	nAcN1  += D1_QUANT
	nAcN2  += xmoeda((D1_TOTAL - D1_VALDESC),(cAliasSF1)->F1_MOEDA,mv_par16,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
	If MV_PAR21==1
		Li++
	Endif
	dbSkip()
End // Nota
Return