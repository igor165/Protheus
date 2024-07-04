#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "EICAM102.ch"

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # EICAM102()                                 # 
############################################################
# Retorno :    #                                           #
############################################################
# Descrição :  # CRIAÇÃO DA TELA DE CADASTRO DE UNIDADE DE #
#              # PREÇO.                                     #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function EICAM102()

	Local cldAlt 	 := ".T."
	Local cldExc 	 := "U_AM102DEL()"
	Private cpString := "EW8"
    Private oUpdAtu
    
    //*** GFP - Tratamento para carga padrão da tabela EW8 - 19/08/2011
    If FindFunction("AvUpdate01")
      oUpdAtu := AvUpdate01():New()
    EndIf

    If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
       If ChkFile("EW8")
          oUpdAtu:aChamados := {{nModulo,{|o| IDadosEW8(o)}}}
          oUpdAtu:Init(,.T.)
       EndIf
    EndIf
    //*** Fim GFP

	If Select ("EW8") < 0
		Aviso(STR0002,STR0004,{STR0003})
		Return .F.
	Endif
	
	dbSelectArea("EW8") 
	dbSetOrder(1)
	
	AxCadastro(cpString,STR0001,cldExc,cldAlt)
	
Return

Static Function IDadosEW8(o)
o:TableStruct('EW8',{'EW8_FILIAL','EW8_CODPRC','EW8_DESPRC','EW8_FORMUL'},1)
o:TableData("EW8",{"01","001","PRECO                                             ","SW6->W6_CONTA20                                                                                                                                                                                         "},,.F.)
o:TableData("EW8",{"01","001","PRECO                                             ","SW6->W6_CONTA20                                                                                                                                                                                         "},,.F.)
o:TableData("EW8",{"  ","001","Container 20'                                     ","SW6->W6_CONTA20                                                                                                                                                                                         "},,.F.)
o:TableData("EW8",{"  ","002","Container 40'                                     ","SW6->W6_CONTA40                                                                                                                                                                                         "},,.F.)
o:TableData("EW8",{"  ","003","Volume/Pallet                                     ","SW6->W6_VOLUME                                                                                                                                                                                          "},,.F.)
o:TableData("EW8",{"  ","004","m3                                                ","SW6->W6_MT3                                                                                                                                                                                             "},,.F.)
o:TableData("EW8",{"  ","005","Pallet                                            ","EVAL({||MsgInfo('Favor informar o campo Quantidade!'),0})                                                                                                                                               "},,.F.)
o:TableData("EW8",{"  ","006","Veículo                                           ","EVAL({||MsgInfo('Favor informar o campo Quantidade!'),0})                                                                                                                                               "},,.F.)
o:TableData("EW8",{"  ","007","% CIF R$                                          ","EVAL({||(DI500RetVal('ITEM_INV', 'TAB', .T.,, .T.) * SW9->W9_TX_FOB)})                                                                                                                                  "},,.F.)
o:TableData("EW8",{"  ","008","Por dia                                           ","EVAL({||MsgInfo('Favor informar o campo Quantidade!'),0})                                                                                                                                               "},,.F.)
o:TableData("EW8",{"  ","009","Viagem                                            ","EVAL({||MsgInfo('Favor informar o campo Quantidade!'),0})                                                                                                                                               "},,.F.)
o:TableData("EW8",{"  ","010","Por hora                                          ","EVAL({||MsgInfo('Favor informar o campo Quantidade!'),0})                                                                                                                                               "},,.F.)
o:TableData("EW8",{"  ","011","Por Lote                                          ","SWV->WV_QTDE                                                                                                                                                                                            "},,.F.)
o:TableData("EW8",{"  ","012","P/ Qtd. Total Container                           ","SW6->(W6_CONTA20+W6_CONTA40+W6_CON40HC+W6_OUTROS)                                                                                                                                                       "},,.F.)
o:TableData("EW8",{"  ","013","Por Toneladas                                     ","SW6->W6_PESOL                                                                                                                                                                                           "},,.F.)

Return Nil

User Function AM102DEL()
	Local alArea  := GetArea()
	Local llRet   := .T.
	Local clSql   := ""
	Local clAlias := GetNextAlias()

	clSql := "SELECT EWD_FILIAL FROM "+RetSqlName("EWD")
	clSql += " WHERE D_E_L_E_T_ = ' '"
	clSql += " AND   EWD_FILIAL = '"+xFilial("EWD")+"'"
	clSql += " AND   EWD_CODPRC = '"+EW8->EW8_CODPRC+"'"

	clAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,clSql),clAlias, .T., .T.)
	dbSelectArea(clAlias)
	
	if (clAlias)->(!eof())
		ApMsgStop(STR0005)
		llRet := .F.
	Endif
	(clAlias)->(dbCloseArea())

	RestArea(alArea)
Return llRet
