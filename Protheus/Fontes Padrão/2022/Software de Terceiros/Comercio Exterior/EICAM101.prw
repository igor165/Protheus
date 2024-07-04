#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "EICAM101.ch"

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # EICAM101                                   # 
############################################################
# Retorno :    #                                           #
############################################################
# Descrição :  # CRIAÇAO DA TELA DE DE CADASTRO DE SERVIÇOS #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function EICAM101()

	Local cldAlt 	 := ".T."
	Local cldExc 	 := "u_AM101DEL()"
	Private cpString := "EWD"
    Private oUpdAtu    

    //*** GFP - Tratamento para carga padrão da tabela EWD - 19/08/2011
    If FindFunction("AvUpdate01")
      oUpdAtu := AvUpdate01():New()
    EndIf

    If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
       If ChkFile("EWD") .And. IsVazio("EWD")
          oUpdAtu:aChamados := {{nModulo,{|o| IDadosEWD(o)}}}
          oUpdAtu:Init(,.T.)
       EndIf
    EndIf
    //*** Fim GFP

	If Select("EWD") < 0
		Aviso(STR0002,STR0004,{STR0003})
		Return .F.
	EndIf
	
	dbSelectArea("EWD")   
	dbSetOrder(1)
	
	AxCadastro(cpString,STR0001,cldExc,cldAlt)
	
Return

Static Function IDadosEWD(o)
o:TableStruct('EWD',{'EWD_FILIAL','EWD_CODSRV','EWD_DESSRV','EWD_CODPRC','EWD_CDTINI','EWD_CDTFIM','EWD_CDTPRV'},1)
o:TableData('EWD',{'01','01 ','Servico Armazenagem                               ','001','EWG->EWG_DT_INI                                                                                                                                                                                         ','EWG->EWG_DT_FIM                                                                                                                                                                                         ','                                                                                                                                                                                                        '},,.F.)
o:TableData('EWD',{'01','09 ','Servico de Armazenagem                            ','001','EWG->EWG_DT_INI                                                                                                                                                                                         ','EWG->EWG_DT_FIM                                                                                                                                                                                         ','                                                                                                                                                                                                        '},,.F.)
o:TableData('EWD',{'01','01 ','Cabotagem                                         ','012','M->EWG_DT_INI                                                                                                                                                                                           ','M->EWG_DT_FIM                                                                                                                                                                                           ','M->EWG_PRVFIM                                                                                                                                                                                           '},,.F.)
o:TableData('EWD',{'01','02 ','Armazenagem da Mercadoria                         ','007','M->EWG_DT_INI                                                                                                                                                                                           ','M->EWG_DT_FIM                                                                                                                                                                                           ','M->EWG_PRVFIM                                                                                                                                                                                           '},,.F.)
o:TableData('EWD',{'01','03 ','Transbordo                                        ','013','M->EWG_DT_INI                                                                                                                                                                                           ','M->EWG_DT_FIM                                                                                                                                                                                           ','M->EWG_PRVFIM                                                                                                                                                                                           '},,.F.)
o:TableData('EWD',{'01','04 ','Levante de conteineres (handling out)             ','012','M->EWG_DT_INI                                                                                                                                                                                           ','M->EWG_DT_FIM                                                                                                                                                                                           ','M->EWG_PRVFIM                                                                                                                                                                                           '},,.F.)
o:TableData('EWD',{'01','05 ','Reprogramacao de retirada de importacao           ','009','M->EWG_DT_INI                                                                                                                                                                                           ','M->EWG_DT_FIM                                                                                                                                                                                           ','M->EWG_PRVFIM                                                                                                                                                                                           '},,.F.)
o:TableData('EWD',{'01','06 ','Movimentacao de container p/ estufagem/desova/fum.','012','M->EWG_DT_INI                                                                                                                                                                                           ','M->EWG_DT_FIM                                                                                                                                                                                           ','M->EWG_PRVFIM                                                                                                                                                                                           '},,.F.)
o:TableData('EWD',{'01','07 ','Vistoria de Carga                                 ','006','M->EWG_DT_INI                                                                                                                                                                                           ','M->EWG_DT_FIM                                                                                                                                                                                           ','M->EWG_PRVFIM                                                                                                                                                                                           '},,.F.)
o:TableData('EWD',{'01','08 ','Separacao de Mercadoria                           ','012','M->EWG_DT_INI                                                                                                                                                                                           ','M->EWG_DT_FIM                                                                                                                                                                                           ','M->EWG_PRVFIM                                                                                                                                                                                           '},,.F.)

Return Nil

User Function AM101DEL()
	Local alArea  := GetArea()
	Local llRet   := .T.
	Local clSql   := ""
	Local clAlias := GetNextAlias()

	clSql := "SELECT EWF_FILIAL FROM "+RetSqlName("EWF")
	clSql += " WHERE D_E_L_E_T_ = ' '"
	clSql += " AND   EWF_FILIAL = '"+xFilial("EWF")+"'"
	clSql += " AND   EWF_CODSRV = '"+EWD->EWD_CODSRV+"'"

	clAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,clSql),clAlias, .T., .T.)
	dbSelectArea(clAlias)
	
	if (clAlias)->(!eof())
		ApMsgStop(STR0005)
		llRet := .F.
	Endif
	(clAlias)->(dbCloseArea())


	clSql := "SELECT EWH_FILIAL FROM "+RetSqlName("EWH")
	clSql += " WHERE D_E_L_E_T_ = ' '"
	clSql += " AND   EWH_FILIAL = '"+xFilial("EWF")+"'"
	clSql += " AND   EWH_CODSRV = '"+EWD->EWD_CODSRV+"'"

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
