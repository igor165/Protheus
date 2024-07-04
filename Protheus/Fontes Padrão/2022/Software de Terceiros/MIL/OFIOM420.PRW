// ษออออออออหออออออออป
// บ Versao บ 23     บ
// ศออออออออสออออออออผ
#include "Protheus.ch"
#include "OFIOM420.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIOM420 บ Autor ณ MIL                บ Data ณ  01/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcoes Auxiliares para tratamento de Inconveniente        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ OFIOM420 ณ Autor ณ  Andre Luis Almeida   ณ Data ณ 26/10/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Consulta / Importacao dos Inconvenientes no Orcamento      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ _cGru       = Grupo de Inconveniente                       ณฑฑ
ฑฑณ          ณ _cCod       = Codigo do Inconveniente                      ณฑฑ
ฑฑณ          ณ _cChaInt    = Chassi Interno do Veiculo                    ณฑฑ
ฑฑณ          ณ _nKM        = KM do Veiculo                                ณฑฑ
ฑฑณ          ณ _cTipTem    = Tipo de Tempo                                ณฑฑ
ฑฑณ          ณ _cDes       = Descricao do Inconveniente                   ณฑฑ
ฑฑณ          ณ _bExibeTela = (Parametro Obsoleto)                         ณฑฑ
ฑฑณ          ณ               Nao sera exibido mais nenhuma tela           ณฑฑ
ฑฑณ          ณ _cTipTemSrv = Tipo de Tempo de Servico                     ณฑฑ
ฑฑณ          ณ _lCliente   = Indica se vai ser utilizado para cliente     ณฑฑ
ฑฑณ          ณ               Considerado quando for inc. de 1ช Revisao    ณฑฑ
ฑฑณ          ลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ _lVlPecSrv  = Indica se vai retornar o valor das pecas e   ณฑฑ
ฑฑณ          ณ               dos servicos                                 ณฑฑ
ฑฑณ          ณ _cFormul    = Indica a formula utilizada no valor da Peca  ณฑฑ
ฑฑณ          ณ _cCodCli    = Indica o Cod. do Cliente que sera utilizado  ณฑฑ
ฑฑณ          ณ               para buscar o VALOR DA HORA DO SERVICO       ณฑฑ
ฑฑณ          ณ _cLojCli    = Indica a Loja do Cliente que sera utilizado  ณฑฑ
ฑฑณ          ณ               para buscar o VALOR DA HORA DO SERVICO       ณฑฑ
ฑฑณ          ลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ _lMsg       = Indica se mostra mensagem qdo inconveniente  ณฑฑ
ฑฑณ          ณ               nao pode ser utilizado                       ณฑฑ
ฑฑบ          ณ _nTpCliente = Tipo de Cliente - 1 = Cliente                บฑฑ
ฑฑบ          ณ                                 2 = Fabrica                บฑฑ
ฑฑบ          ณ                                 3 = Concessionaria         บฑฑ
ฑฑบ          ณ                                 4 = Outros                 บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Oficina                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM420(_cGru,_cCod,_cChaInt,_nKM,_cTipTem,_cDes,_bExibeTela,_cTipTemSrv,_lCliente,_lVlPecSrv,_cFormul,_cCodCli,_cLojCli,_lMsg,_nTpCliente)
Local bCampo   := { |nCPO| Field(nCPO) }
Local ni       := 0
Local cQuery   := ""
Local cQAlVAJ  := "SQLVAJ"
Local nVlPecSrv  := 0
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela
Local _MsgErro   := ""
Local lVAJGRUMOD := (VAJ->(FieldPos("VAJ_GRUMOD")) > 0)
Local lVAJAPLICA := (VAJ->(FieldPos("VAJ_APLICA")) > 0)
Local lVSLSPPS1R := (VSL->(FieldPos("VSL_SPPS1R")) > 0)
Local cAuxTpSer := ""
Local cCpoTpSer := ""
Local lIncSer := .f.
Local lIncItem := .f.
Local cAuxChave := "" 
Local lAchou    := .f.
Private _cGruInc := ""
Private _cCodInc := ""
Private _cDesInc := ""
Private aRetInc  := {{},{},.f.}
Private cCodMar  := "" // Variavel utilizada no SXB
Private cCodMod  := "" // Variavel utilizada no SXB
Private cGruMod  := "" 
Private cAplica  := "" 
Private get_grupo:= "" // Variavel utilizada no SXB
Private aRotina  := {{"","" , 0 , 1},; // Pesquisar
				  	 {"","", 0 , 2} ,; // Consultar
					 {"","", 0 , 3} ,; // Incluir
					 {"","", 0 , 4 },; // Alterar
					 {"","", 0 , 5 } } // Excluir

Default _cGru := ""
Default _cCod := ""
Default _cDes := ""
Default _bExibeTela := .f.
Default _cTipTem    := ""
Default _cTipTemSrv := _cTipTem
Default _lCliente   := .f.

Default _lVlPecSrv  := .f. // Retorna os VALORES de PECAS e SERVICOS
Default _cFormul    := ""  // Formula para calculo da PECA
Default _cCodCli    := ""  // Codigo do Cliente para buscar o VALOR DA HORA DO SERVICO
Default _cLojCli    := ""  // Loja do Cliente para buscar o VALOR DA HORA DO SERVICO

Default _lMsg       := .t.

Default _nTpCliente := 1

_cGruInc := _cGru
_cCodInc := _cCod
_cDesInc := _cDes

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek( xFilial("VV1") + _cChaInt )

cCodMar := VV1->VV1_CODMAR
cCodMod := VV1->VV1_MODVEI
cGruMod := FM_SQL("SELECT VV2_GRUMOD FROM "+RetSQLName("VV2")+" WHERE VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2_CODMAR = '"+VV1->VV1_CODMAR+"' AND VV2_MODVEI = '"+VV1->VV1_MODVEI+"' AND D_E_L_E_T_ = ' '")
cAplica := SubStr(VV1->VV1_CHASSI,4,4)

// Valida se existe inconveniente ...
if !Empty(_cGruInc) .and. !Empty(_cCodInc)
	DbSelectArea("VSL") 
	DbSetOrder(1) // VSL_FILIAL+VSL_CODMAR+VSL_CODGRU+VSL_CODINC
	if !VSL->(dbSeek(xFilial("VSL")+VV1->VV1_CODMAR+_cGruInc+_cCodInc))
		dbSelectArea("VSL")
		dbSetOrder(1) // VSL_CODMAR+VSL_CODGRU+VSL_CODINC
		if !dbSeek(xFilial("VSL") + Space(TamSX3("VV1_CODMAR")[1]) + _cGruInc+_cCodInc)
			MsgStop(STR0019,STR0004)
			Return aRetInc
		endif
	Endif	
endif
//

DbSelectArea("SB1")
DbSetOrder(7)
DbSelectArea("VSL") 
DbSetOrder(1) // VSL_FILIAL+VSL_CODMAR+VSL_CODGRU+VSL_CODINC
If DbSeek(xFilial("VSL")+VV1->VV1_CODMAR+_cGruInc+_cCodInc)
  lAchou := .t.
Else
	DbSelectArea("VSL") 
	DbSetOrder(1) // VSL_FILIAL+VSL_CODMAR+VSL_CODGRU+VSL_CODINC
	If DbSeek(xFilial("VSL")+Space(TamSX3("VV1_CODMAR")[1])+_cGruInc+_cCodInc)
     	lAchou := .t.
	Endif
Endif     
if lAchou 
	// VALIDA PECAS //
	If _lMsg .and. !OM420VALINC("P",_cGruInc,_cCodInc,_cChaInt,_nKM,_cTipTem,,,,@_MsgErro)
		MsgStop(_MsgErro+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0012+" "+_cGruInc+" "+_cCodInc,STR0004) // "Inconveniente nao pode ser utilizado para este Veiculo / Tipo de Tempo." / "Grupo / Codigo Inconveniente:" / "Tipo de Tempo:" / "Atencao"
	EndIf 
	//
	
	// VALIDA SERVICOS //
	If _lMsg .and. !OM420VALINC("S",_cGruInc,_cCodInc,_cChaInt,_nKM,_cTipTemSrv,,,,@_MsgErro)
		MsgStop(_MsgErro+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0012+" "+_cGruInc+" "+_cCodInc,STR0004) // "Inconveniente nao pode ser utilizado para este Veiculo / Tipo de Tempo." / "Grupo / Codigo Inconveniente:" / "Tipo de Tempo:" / "Atencao"
	EndIf
	//
	
	_cDesInc := VSL->VSL_DESINC
	
	cAuxChave := ""
	
	cQuery := "SELECT VAJ.VAJ_GRUPEC , VAJ.VAJ_CODPEC , VAJ.VAJ_QTDPEC , VAJ.VAJ_GRUSER, VAJ.VAJ_CODSER , VAJ.VAJ_TIPSER , VAJ.VAJ_TSCONC, VAJ.VAJ_TSFABR, VAJ.VAJ_TSOUTR , VAJ.VAJ_CODSEC , VAJ.VAJ_CODMOD "
	If lVAJGRUMOD
		cQuery += " , VAJ.VAJ_GRUMOD"
	EndIf
	If lVAJAPLICA
		cQuery += " , VAJ.VAJ_APLICA"
	EndIf
	cQuery +=  " FROM "+RetSQLName("VAJ")+" VAJ "
	cQuery += " WHERE VAJ.VAJ_FILIAL='"+xFilial("VAJ")+"'"
	cQuery +=   " AND (VAJ.VAJ_CODMAR='"+VV1->VV1_CODMAR+"' OR VAJ.VAJ_CODMAR = ' ')"
	cQuery +=   " AND VAJ.VAJ_CODGRU='"+_cGruInc+"'"
	cQuery +=   " AND VAJ.VAJ_CODINC='"+_cCodInc+"'"
	// Primeira revisao //
	If VSL->VSL_TIPO == "2"
		If lVSLSPPS1R .and. VSL->VSL_SPPS1R == "0"
		Elseif !(GetNewPar("MV_MIL0006", " ") == 'JD') // Separa Pe็as e Servi็os na 1a revisใo
			If _lCliente // Cliente paga somente PECAS
				cQuery += " AND VAJ.VAJ_CODSER = '"+Space(TamSX3("VAJ_CODSER")[1])+"'"
			Else // Concessionaria paga somente SERVICOS
				cQuery += " AND VAJ.VAJ_GRUPEC = '"+Space(TamSX3("VAJ_GRUPEC")[1])+"' AND VAJ.VAJ_CODPEC = '"+Space(TamSX3("VAJ_CODPEC")[1])+"'"
			EndIf
		EndIf
	EndIf
	//
	cQuery +=   " AND VAJ.D_E_L_E_T_=' '"
	cQuery += " ORDER BY VAJ.VAJ_GRUPEC , VAJ.VAJ_CODPEC , VAJ.VAJ_GRUSER , VAJ.VAJ_CODSER "
	cQuery += " , VAJ.VAJ_CODMOD DESC "
	If lVAJGRUMOD
		cQuery += " , VAJ.VAJ_GRUMOD DESC "
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAJ, .F., .T. )
	While !( cQAlVAJ )->( Eof() )
	
		lIncItem := .t.
		If cAuxChave == ( cQAlVAJ )->( VAJ_GRUPEC ) + ( cQAlVAJ )->( VAJ_CODPEC ) + ( cQAlVAJ )->( VAJ_GRUSER ) + ( cQAlVAJ )->( VAJ_CODSER )
			( cQAlVAJ )->(dbSkip())
			Loop
		ElseIf !Empty(cAuxChave)
			cAuxChave := ""
		EndIf

		// Valida servico por modelo 
		If lIncItem .and. !Empty(( cQAlVAJ )->VAJ_CODMOD) .and. ( cQAlVAJ )->VAJ_CODMOD <> cCodMod
			lIncItem := .f.
		EndIf
		
		// Valida servico por Grupo de modelo 
		If lVAJGRUMOD .and. lIncItem .and. !Empty(( cQAlVAJ )->VAJ_GRUMOD) .and. ( cQAlVAJ )->VAJ_GRUMOD <> cGruMod
			lIncItem := .f.
		EndIf
		
		// Valida servico por Aplicacao 
		If lVAJAPLICA .and. lIncItem .and. !Empty(( cQAlVAJ )->VAJ_APLICA) .and. AllTrim(( cQAlVAJ )->VAJ_APLICA) <> AllTrim(cAplica)
			lIncItem := .f.
		EndIf
		
		If !lIncItem
			( cQAlVAJ )->( DbSkip() )
			Loop
		EndIf
		
		cAuxChave := ( cQAlVAJ )->( VAJ_GRUPEC ) + ( cQAlVAJ )->( VAJ_CODPEC ) + ( cQAlVAJ )->( VAJ_GRUSER ) + ( cQAlVAJ )->( VAJ_CODSER )
		
		// Pecas 
		If !Empty(( cQAlVAJ )->( VAJ_GRUPEC )) .and. !Empty(( cQAlVAJ )->( VAJ_CODPEC )) .and. ( cQAlVAJ )->( VAJ_QTDPEC ) > 0

			If SB1->(DbSeek( xFilial("SB1") + ( cQAlVAJ )->( VAJ_GRUPEC ) + ( cQAlVAJ )->( VAJ_CODPEC ) ))
				If SB1->B1_MSBLQL == "1"
					HELP(" ",1,"REGBLOQ")
				Else
					If _lVlPecSrv
						//
						nVlPecSrv := FG_VALPEC( _cTipTem , '"'+_cFormul+'"' , ( cQAlVAJ )->( VAJ_GRUPEC ) , ( cQAlVAJ )->( VAJ_CODPEC ) , , .f. , .t. )
						nVlPecSrv := ( nVlPecSrv * ( cQAlVAJ )->( VAJ_QTDPEC ) )
						//
						AADD(aRetInc[1],{ ( cQAlVAJ )->( VAJ_GRUPEC ),;	// 1 - Grupo
										  ( cQAlVAJ )->( VAJ_CODPEC ),;	// 2 - CodIte
										  ( cQAlVAJ )->( VAJ_QTDPEC ),;	// 3 - Qtdade
										  _cGruInc ,;                  	// 4 - Grupo.Inconveniente
										  _cCodInc ,;                   // 5 - Cod.Inconveniente
										  _cDesInc ,;                   // 6 - Descr.Inconveniente
										  nVlPecSrv })                  // 7 - Valor Total das Pecas
						//
					Else
						//
						AADD(aRetInc[1],{ ( cQAlVAJ )->( VAJ_GRUPEC ),;	// 1 - Grupo
										  ( cQAlVAJ )->( VAJ_CODPEC ),;	// 2 - CodIte
										  ( cQAlVAJ )->( VAJ_QTDPEC ),;	// 3 - Qtdade
										  _cGruInc ,;                   // 4 - Grupo.Inconveniente
										  _cCodInc ,;                   // 5 - Cod.Inconveniente
										  _cDesInc })                   // 6 - Descr.Inconveniente
						//
					EndIf
				EndIf
			EndIf

		EndIf
		// Servicos 
		If !Empty(( cQAlVAJ )->( VAJ_CODSER ))
		
			lIncSer := .t.
		
			cAuxTpSer := ""
			cCpoTpSer := ""
			Do Case
			Case _nTpCliente == 1 	// Cliente 
				cCpoTpSer := "VAJ_TIPSER"
			Case _nTpCliente == 2	// Fabrica 
				cCpoTpSer := "VAJ_TSFABR"
			Case _nTpCliente == 3 	// Concessionaria 
				cCpoTpSer := "VAJ_TSCONC"
			Case _nTpCliente == 4 	// Outros 
				cCpoTpSer := "VAJ_TSOUTR"
			End Case
			
			cAuxTpSer := &(cQAlVAJ + "->" + cCpoTpSer)
			If Empty(cAuxTpSer)
				If _lMsg
					MsgInfo(STR0024 + "(" + cCpoTpSer + ")" + chr(13) + chr(10) + ; // "Servi็o sem tipo de servi็o informado no cadastro de inconveniente."
							STR0025 ) // "O mesmo nใo serแ adicionado."
				EndIf
				lIncSer := .f.
			Endif

			If lIncSer
				If _lVlPecSrv
					//
					nVlPecSrv := FMX_VALSER( _cTipTem , ( cQAlVAJ )->( VAJ_TIPSER ) , VV1->VV1_CODMAR , ( cQAlVAJ )->( VAJ_CODSER ) , _cCodCli , _cLojCli , VV1->VV1_CHAINT, VV1->VV1_MODVEI, VV1->VV1_SEGMOD )
                    //
					AADD(aRetInc[2],{ ( cQAlVAJ )->( VAJ_GRUSER ) ,;	// 1 - Grupo
									  ( cQAlVAJ )->( VAJ_CODSER ) ,;	// 2 - CodSrv
									  cAuxTpSer ,;						// 3 - TipSrv
									  _cGruInc ,;                   	// 4 - Grupo.Inconveniente
									  _cCodInc ,;                   	// 5 - Cod.Inconveniente
									  _cDesInc ,;                   	// 6 - Descr.Inconveniente
									  ( cQAlVAJ )->( VAJ_CODSEC ),; 	// 7 - Cod.Secao 
									  nVlPecSrv })                  	// 8 - Valor Total dos Servicos
					//
				Else
					//
					AADD(aRetInc[2],{ ( cQAlVAJ )->( VAJ_GRUSER ) ,;	// 1 - Grupo
									  ( cQAlVAJ )->( VAJ_CODSER ) ,;	// 2 - CodSrv
									  cAuxTpSer ,;						// 3 - TipSrv
									  _cGruInc ,;                    	// 4 - Grupo.Inconveniente
									  _cCodInc ,;                    	// 5 - Cod.Inconveniente
									  _cDesInc ,;                    	// 6 - Descr.Inconveniente
									  ( cQAlVAJ )->( VAJ_CODSEC )})  	// 7 - Cod.Secao 
					//
				EndIf
			EndIf

	   	EndIf
		( cQAlVAJ )->( DbSkip() )
	EndDo
	( cQAlVAJ )->( dbCloseArea() )
EndIf
DbSelectArea("SB1")
DbSetOrder(1)

aRetInc[3] := .t. // Retorno OK
	
Return(aRetInc)

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Fun็ใo    | OM420CONSINC  | Autor | Rubens Takahashi   | Data | 12/01/10 |##
##+----------+---------------+-------+--------------------+------+----------+##
##|Descri็ใo | Retorna o Informacoes do Inconveniente                       |##
##+----------+--------------------------------------------------------------+##
##|Parametros| _cTpReg  = Tipo do Registro a ser consultado                 |##
##|          |          1=Orcamento / 2=OS / 3=Agendamento                  |##
##|          | _cCodigo = Cod. do Orcamento / OS / Agendamento              |##
##|          | _cSeq = Sequencia do Inconveniente                           |##
##|          | _cGrupo = Grupo do Inconveniente                             |##
##|          | _cInconv = Codigo do Inconveniente                           |##
##|          | _cDescricao = Descricao do Inconveniente                     |##
##+----------+--------------------------------------------------------------+##
##|Retorno   | { Grupo , Codigo , Descricao , Sequencia }                   |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM420CONSINC( _cTpReg, _cCodigo, _cSeq, _cGrupo, _cInconv, _cDescricao )
Local aRetorno := {"","","","","",""} , cQuery, cQAUXCONS := "SQLVSTCON"
Local oArea := GetArea()
Local lChassi := ( VST->(FieldPos("VST_CHASSI")) > 0 )

Default _cSeq := ""
Default _cGrupo := ""
Default _cInconv := ""
Default _cDescricao := ""

If lChassi
	cQuery := "SELECT VST_SEQINC, VST_GRUINC, VST_CODINC, VST_DESINC, VST_CODMAR , VST_CHASSI "
Else
	cQuery := "SELECT VST_SEQINC, VST_GRUINC, VST_CODINC, VST_DESINC, VST_CODMAR "
EndIf
cQuery +=  " FROM " + RetSQLName("VST") + " VST "
cQuery += " WHERE VST_FILIAL= '" + xFilial("VST") + "'"
cQuery +=   " AND VST_TIPO = '" + _cTpReg + "'"
cQuery +=   " AND VST_CODIGO = '" + _cCodigo + "'"
cQuery += if( !Empty(_cSeq) , " AND VST_SEQINC ='" + _cSeq + "'", "")
cQuery += if( !Empty(_cGrupo) .and. !Empty(_cInconv) , " AND VST_GRUINC = '" + _cGrupo + "' AND VST_CODINC = '" + _cInconv + "'", "")
cQuery += if( !Empty(_cDescricao) , " AND VST_DESINC ='" + _cDescricao + "'", "")
cQuery +=   " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAUXCONS, .F., .T. )
(cQAUXCONS)->(dbGoTop())
if !(cQAUXCONS)->(Eof())
	aRetorno[1] := (cQAUXCONS)->VST_GRUINC
	aRetorno[2] := (cQAUXCONS)->VST_CODINC
	aRetorno[3] := (cQAUXCONS)->VST_DESINC
	aRetorno[4] := (cQAUXCONS)->VST_SEQINC
	aRetorno[5] := (cQAUXCONS)->VST_CODMAR
	If lChassi
		aRetorno[6] := (cQAUXCONS)->VST_CHASSI
	EndIf
else
	aRetorno[1] := Space(TamSX3("VST_GRUINC")[1])
	aRetorno[2] := Space(TamSX3("VST_CODINC")[1])
	aRetorno[3] := Space(TamSX3("VST_DESINC")[1])
	aRetorno[4] := Space(TamSX3("VST_SEQINC")[1])
	aRetorno[5] := Space(TamSX3("VST_CODMAR")[1])
	If lChassi
		aRetorno[6] := Space(TamSX3("VST_CHASSI")[1])
	EndIf
endif
(cQAUXCONS)->(dbCloseArea())
RestArea( oArea )

Return aRetorno 

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Fun็ใo    | OX001SELINCON | Autor | Rubens Takahashi   | Data | 06/01/10 |##
##+----------+---------------+-------+--------------------+------+----------+##
##|Descri็ใo | Exibe uma tela para o usuario selecionar dentre os inconv.   |##
##|          | ja selecionados no orcamento, um inconveniente para a peca   |##
##|          | ou servico digitada manualmente                              |##
##+----------+--------------------------------------------------------------+##
##|Parametros| _aAuxACols - aCols com Campos de Informacoes do Inconveniente|##
##|          | _aPosCpoInc - Posicao do aHeader para os Campos de           |##
##|          |               Inconveniente                                  |##
##|          | _oMainWnd - Dialog principal que chamou essa funcao          |##
##|          | _cTpReg  = Tipo do Registro a ser consultado                 |##
##|          |          1=Orcamento / 2=OS / 3=Agendamento                  |##
##|          | _cCodigo = Cod. do Orcamento / OS / Agendamento              |##
##+----------+--------------------------------------------------------------+##
##|Retorno   | { Grupo , Codigo , Descricao , Sequencia }                   |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM420SELINCON(_aAuxACols, _aPosCpoInc, _oMainWnd, _cTpReg, _cCodigo , cTitTela )

Local aObjects := {} , aPosObj := {} , aInfo := {} , aSizeAut := MsAdvSize(.t.) // Variaveis para posicionamento de Tela
Local nCont, aSelInconv := {}
Local aRetorno := {"","","",""}
Local oOrcInc, cQuery, cSQLCON := "SQLVSTTMP"
Local oArea := GetArea()
Local nPos := 1

Local nPosSeqInc := 1 // Posicao da Seq. no Vetor passado como parametro 
Local nPosGruInc := 2 // Posicao do Grupo no Vetor passado como parametro 
Local nPosCodInc := 3 // Posicao do Codigo no Vetor passado como parametro 
Local nPosDesInc := 4 // Posicao da Descricao no Vetor passado como parametro 

Default _cTpReg := ""
Default _cCodigo := ""
Default cTitTela := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta matriz a partir da aCols com os Inconvenientes jแ selecionadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nCont := 1 to Len(_aAuxACols)
	// se a linha nao estiver excluida 
	if !_aAuxACols[nCont,Len(_aAuxACols[nCont])]
		// So adiciona se a linha nao estiver em branco  
		// Grupo e Codigo nao estiver em branco OU Descricao nao estiver em branco 
		if (!Empty(_aAuxACols[nCont,_aPosCpoInc[nPosGruInc]]) .and. !Empty(_aAuxACols[nCont,_aPosCpoInc[nPosCodInc]])) .or. !Empty(_aAuxACols[nCont,_aPosCpoInc[nPosDesInc]])
			if ( aScan(aSelInconv, { |x| x[1] == _aAuxACols[nCont,_aPosCpoInc[nPosGruInc]] .and. x[2] == _aAuxACols[nCont,_aPosCpoInc[nPosCodInc]] .and. x[3] == _aAuxACols[nCont,_aPosCpoInc[nPosDesInc]] } ) == 0 )
				AADD(aSelInconv, { _aAuxACols[nCont,_aPosCpoInc[nPosGruInc]] ,;
									_aAuxACols[nCont,_aPosCpoInc[nPosCodInc]] ,;
									_aAuxACols[nCont,_aPosCpoInc[nPosDesInc]] ,;
									_aAuxACols[nCont,_aPosCpoInc[nPosSeqInc]] } )
			endif
		endif
	endif
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta matriz a partir do Banco de Dados com os Inconvenientes jแ selecionadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if !Empty(_cTpReg)
	cQuery := "SELECT VST_SEQINC, VST_GRUINC, VST_CODINC, VST_DESINC"
	cQuery +=  " FROM " + RetSQLName("VST") + " VST"
	cQuery += " WHERE VST.VST_FILIAL = '" + xFilial("VST") + "'"
	cQuery +=   " AND VST.VST_TIPO = '" + _cTpReg + "'"
	cQuery +=   " AND VST.VST_CODIGO = '" + _cCodigo + "'"
	cQuery +=   " AND VST.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLCON, .F., .T. )
	(cSQLCON)->(dbGoTop())
	Do While !(cSQLCON)->(Eof())
		if ( aScan(aSelInconv, { |x| x[1] == (cSQLCON)->VST_GRUINC .and. x[2] == (cSQLCON)->VST_CODINC .and. x[3] == (cSQLCON)->VST_DESINC } ) == 0 )
			AADD(aSelInconv, { (cSQLCON)->VST_GRUINC ,;
								(cSQLCON)->VST_CODINC ,;
								(cSQLCON)->VST_DESINC ,;
								(cSQLCON)->VST_SEQINC } )
		endif 
		(cSQLCON)->(DbSkip())
	End
	(cSQLCON)->(dbCloseArea())
	RestArea( oArea )
endif

// So exige um inconveniente se tiver sido selecionado ao menos 1 inconveniente
IF Len(aSelInconv) > 0 
	// So exibe a tela para selecao se tiver mais de 1 inconveniente ja cadastrado 
	if Len(aSelInconv) > 1 

		ASort(aSelInconv,,,{ |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]} )

		If Empty(cTitTela)
			cTitTela := STR0014 // Inconvenientes
		EndIf
		
		DEFINE MSDIALOG oOrcInc TITLE STR0014 From aSizeAut[7],00 to Round(aSizeAut[6]*0.6,0),Round(aSizeAut[5]*0.9,0) of _oMainWnd PIXEL // Inconvenientes

		@ aSizeAut[2]+4, aSizeAut[1]+2 Say cTitTela OF oOrcInc PIXEL Font TFont():New( "System", 8, 012 ) SIZE 300,20

		@ aSizeAut[2]+15, aSizeAut[1]+2 LISTBOX oLbInconv FIELDS HEADER RetTitle("VST_GRUINC"),RetTitle("VST_CODINC"),RetTitle("VST_DESINC"); 
					COLSIZES 30,50,90 ;
					SIZE Round(aSizeAut[3]*0.9,0)-aSizeAut[1]-2, Round(aSizeAut[4]*0.6,0)-aSizeAut[2]-21 ;
					OF oOrcInc PIXEL ;
					ON CHANGE (nPos := oLbInconv:nAt) ;
					ON DBLCLICK (oOrcInc:End())

		oLbInconv:SetArray(aSelInconv)
		oLbInconv:bLine := { || {aSelInconv[oLbInconv:nAt,1],;
		                         aSelInconv[oLbInconv:nAt,2],;
		                         aSelInconv[oLbInconv:nAt,3] }}
		oLbInconv:Refresh()
		oOrcInc:lEscClose := .F.
		ACTIVATE MSDIALOG oOrcInc CENTER ON INIT EnchoiceBar(oOrcInc, { || oOrcInc:End() } , { || MsgAlert(STR0015),.f. } )
	endif	
	//
	
	aRetorno[1] := aSelInconv[nPos,1] // Grupo     
	aRetorno[2] := aSelInconv[nPos,2] // Codigo    
	aRetorno[3] := aSelInconv[nPos,3] // Descricao 
	aRetorno[4] := aSelInconv[nPos,4] // Sequencia 
	
else

	aRetorno[1] := Space(TamSX3("VST_GRUINC")[1])
	aRetorno[2] := Space(TamSX3("VST_CODINC")[1])
	aRetorno[3] := Space(TamSX3("VST_DESINC")[1])
	aRetorno[4] := Space(TamSX3("VST_SEQINC")[1])
	
ENDIF

return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM420UTILINC บAutor ณ Rubens Takahashi  บ Data ณ 18/01/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se o Orcam/OS/Agend utilizou algum inconveniente   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ _cTpReg  = Tipo do Registro a ser consultado               บฑฑ
ฑฑบ          ณ          1=Orcamento / 2=OS / 3=Agendamento                บฑฑ
ฑฑบ          ณ _cCodigo = Cod. do Orcamento / OS / Agendamento            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบRetorno   ณ .t. ou .f.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM420UTILINC( _cTpReg, _cCodigo )
Local lRetorno := .f., cQAUXCONS := "SQLVSTCON"
Local oArea := GetArea()

cQuery := "SELECT COUNT(*) CONTADOR"
cQuery +=  " FROM " + RetSQLName("VST") + " VST "
cQuery += " WHERE VST_FILIAL= '" + xFilial("VST") + "'"
cQuery +=   " AND VST_TIPO = '" + _cTpReg + "'"
cQuery +=   " AND VST_CODIGO = '" + _cCodigo + "'"
cQuery +=   " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAUXCONS, .F., .T. )
(cQAUXCONS)->(dbGoTop())
if !(cQAUXCONS)->(Eof()) .AND. (cQAUXCONS)->CONTADOR > 0
	lRetorno := .t.
endif
(cQAUXCONS)->(dbCloseArea())
dbSelectArea("VS4")
RestArea( oArea )

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM420NUMSEQ  บAutor  ณ Rubens Takahashi  บ Data ณ 12/01/10 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Procura proximo numero sequencial para chave do            บฑฑ
ฑฑบ          ณ Inconveniente                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ _cTpReg = Tipo de Registro                                 บฑฑ
ฑฑบ          ณ           1=Orcamento / 2=OS / 3=Agendamento               บฑฑ
ฑฑบ          ณ _cCodigo = Codigo do Inconveniente                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM420NUMSEQ(_cTpReg , _cCodigo)
Local nTamSeqInc := TamSX3("VST_SEQINC")[1]
Local cRetorno

// Nao verifica se o registro esta deletado, para garantir que nao duplicara sequencial 
cRetorno := FM_SQL("SELECT MAX(VST_SEQINC) SEQ FROM " + RetSQLName("VST") + ;
						 " WHERE VST_FILIAL = '" + xFilial("VST") + "'" + ;
						   " AND VST_TIPO = '" + _cTpReg + "'" + ;
						   " AND VST_CODIGO = '" + _cCodigo + "'" )
if Empty(cRetorno)
	cRetorno := StrZero(1,nTamSeqInc)
else
	cRetorno := StrZero(Val(cRetorno)+1,nTamSeqInc)
endif

Return cRetorno 

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |OM420VALINC | Autor | Andre Luis Almeida    | Data | 23/11/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Validacao dos Inconvenientes:                                |##
##|          | - No momento da Digitacao dos Inconvenientes no Orcamento    |##
##|          | - Antes de iniciar o processo de Faturamento                 |##
##+----------+--------------------------------------------------------------+##
##|Parametros| _cTp     = "P" -> Pecas  /  "S" -> Servicos                  |##
##|          | _cGruInc = Grupo do Inconveniente                            |##
##|          | _cCodInc = Codigo do Inconveniente                           |##
##|          | _cChaInt = Chassi Interno do Veiculo                         |##
##|          | _nKM     = KM do Veiculo                                     |##
##|          | _cTipTem = Tipo de Tempo                                     |##
##|          | _cCodigo = Orcamento/OS/Agendamento para pesquisa na VST     |##
##|          | _cTpVST  = Tipo de reg. na VST (1/2/3)                       |##
##|          | _cSeqInc = Sequencia do Inconveniente na VST                 |##
##|          | _MsgErro = Msg de Erro Retornada pela Validacao (Array)      |##
##+----------+--------------------------------------------------------------+##
##|Retorno   | .t. = Inconveniente Correto / .f. = Problema no Inconveniente|##
##+----------+--------------------------------------------------------------+##
##| Uso      | Auto Pecas / Oficina                                         |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM420VALINC(_cTp,_cGruInc,_cCodInc,_cChaInt,_nKM,_cTipTem,_cCodigo,_cTpVST,_cSeqInc,_MsgErro)
Local lRet     := .t.
Local dDiasIni := dDataBase
Local dDiasFin := dDataBase
Local lPodeUsar := .f.     
Local lValidKM := .f.
Local lValidDt := .f.

Default _cGruInc := ""
Default _cCodInc := ""
Default _cSeqInc := ""
Default _cTpVST  := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao for passado grupo e codigo, procurar pela SEQUENCIA na tabela VST ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if Empty(_cGruInc) .and. Empty(_cCodInc) .and. !Empty(_cSeqInc)
	dbSelectArea("VST")
	dbSetOrder(1)
	if VST->(dbSeek( xFilial("VST") + _cTpVST + _cCodigo + _cSeqInc ))
		_cGruInc := VST->VST_GRUINC
		_cCodInc := VST->VST_CODINC
	endif
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe grupo e codigo estiver vazio, trata-se de um inconveniente manualณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(_cGruInc) .and. Empty(_cCodInc)
	Return .t.
EndIf

DbSelectArea("VV1")
DbSetOrder(1) // VV1_FILIAL+VV1_CHAINT
DbSeek(xFilial("VV1")+_cChaInt)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcura Inconvenienteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("VSL") 
DbSetOrder(1) // VSL_FILIAL+VSL_CODMAR+VSL_CODGRU+VSL_CODINC
If !DbSeek(xFilial("VSL")+VV1->VV1_CODMAR+_cGruInc+_cCodInc)
	dbSelectArea("VSL")
	dbSetOrder(1) // VSL_CODMAR+VSL_CODGRU+VSL_CODINC
	if !dbSeek(xFilial("VSL") + Space(TamSX3("VV1_CODMAR")[1]) + _cGruInc+_cCodInc)
		_MsgErro := STR0016
		Return .f. 
	Endif	
EndIf

_MsgErro := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a KM do Veiculo esta na faixa cadastrada no Inconvenienteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if !lPodeUsar
	If VSL->VSL_KILOME <> 0 .or. VSL->VSL_KILFIN <> 0
		lValidKM := .t. // So para indicar que houve validacao por KM ...
		If !(_nKM >= VSL->VSL_KILOME .and. _nKM <= VSL->VSL_KILFIN )
			_MsgErro += IIF(!Empty(_MsgErro),CHR(13)+CHR(10),"") + STR0017
		Else
			lPodeUsar := .t.
		EndIf
	EndIf
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a Data de Venda do Veiculo esta entre a faixa cadastrada no Inconveniente ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if !lPodeUsar
	if VSL->VSL_PERINI <> 0 .or. VSL->VSL_PERFIN <> 0
		lValidDt := .t. // So para indicar que houve validacao por Data ...

		dDiasIni := ( VV1->VV1_DATVEN + VSL->VSL_PERINI )
		dDiasFin := ( VV1->VV1_DATVEN + VSL->VSL_PERFIN )
		If !Empty(dDiasFin) .and. !( dDataBase >= dDiasIni .and. dDataBase <= dDiasFin )
			_MsgErro += IIF(!Empty(_MsgErro),CHR(13)+CHR(10),"") + STR0018
		else
			lPodeUsar := .t.
		EndIf
	endif
endif

if !lPodeUsar .and. !(lValidKM .or. lValidDt)
	lPodeUsar := .t.
endif

lRet := lPodeUsar

Return lRet


/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Fun็ใo    | OM420GRAVA    | Autor | Rubens Takahashi   | Data | 13/01/10 |##
##+----------+---------------+-------+--------------------+------+----------+##
##|Descri็ใo | Grava os registro de inconvenientes utilizados no Orcam./    |##
##|          | OS/Agendamento                                               |##
##+----------+--------------------------------------------------------------+##
##|Parametros| _aAuxACols - aCols com Campos da VST                         |##
##|          | _aAuxAHeader - aHeader do aCols                              |##
##|          | _cTpReg  = Tipo do Registro a ser consultado                 |##
##|          |          1=Orcamento / 2=OS / 3=Agendamento                  |##
##|          | _cCodigo = Cod. do Orcamento / OS / Agendamento              |##
##|          | _cCodMar = Codigo da Marca do Veํculo                        |##
##|          | _cChassi = Chassi do Veํculo                                 |##
##+----------+--------------------------------------------------------------+##
##|Retorno   | .t.                                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM420GRAVA(_aAuxACols, _aAuxAHeader, _cTpReg, _cCodigo, _cCodMar,_cChassi)
Local oArea := GetArea()
Local nCntFor, nCntFor2, nPosSeq, nAuxPos, lNovo
Local cNaoGrava := ""
Local nPosDesInc
Local lChassi := ( VST->(FieldPos("VST_CHASSI")) > 0 )

Default _cTpReg  := ""
Default _cCodigo := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampo de Descricao ้ Obrigatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosDesInc := aScan(_aAuxAHeader,{|x| AllTrim(x[2])=="VST_DESINC"})
if nAuxPos == 0
	Return .f.
endif
//

nPosSeq := aScan(_aAuxAHeader,{|x| AllTrim(x[2])=="VST_SEQINC"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao for passado o Codigo e Tipo do Registro, procura na aCols   ณ
//ณpois serแ necessแrio para verificar se ้ uma inclusao ou alteracao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cNaoGrava += "VST_TIPO,"
cNaoGrava += "VST_CODIGO,"
if Empty(_cTpReg)
	nAuxPos := aScan(_aAuxAHeader,{|x| AllTrim(x[2])=="VST_TIPO"})
	If len(_aAuxACols) > 0 .and. nAuxPos > 0
		_cTpReg := _aAuxACols[1,nAuxPos]
	EndIf
endif
if Empty(_cCodigo)
	nAuxPos := aScan(_aAuxAHeader,{|x| AllTrim(x[2])=="VST_CODIGO"})
	If len(_aAuxACols) > 0 .and. nAuxPos > 0
		_cCodigo := _aAuxACols[1,nAuxPos]	
	EndIf
endif

for nCntFor := 1 to Len(_aAuxACols)

	// Linha nao esta excluida 
	if !_aAuxACols[nCntFor,len(_aAuxACols[nCntFor])]
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe nao tiver DESCRICAO nao serแ gravadoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if Empty(_aAuxACols[nCntFor,nPosDesInc])
			Loop
		Endif
	    
		DBSelectArea("VST")
		dbSetOrder(1)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe nao for informado a sequencia, considerar como registro novoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if Empty(_aAuxACols[nCntFor,nPosSeq])
			lNovo := .t.
		else
			lNovo := !(VST->(dbSeek(xFilial("VST") + _cTpReg + _cCodigo + _aAuxACols[nCntFor,nPosSeq] )))
		endif 
		
		// Se nao foi passado o sequencial, calcula o proximo sequencial 
		if Empty(_aAuxACols[nCntFor,nPosSeq])
			_aAuxACols[nCntFor,nPosSeq] := OM420NUMSEQ(_cTpReg,_cCodigo)
			DBSelectArea("VST")
		endif

		RecLock("VST", lNovo )
		VST->VST_FILIAL := xFilial("VST")
		
		if !Empty(_cTpReg)
			VST->VST_TIPO := _cTpReg // Tipo de Registro de Orcamento 
		endif
		
		if !Empty(_cCodigo)
			VST->VST_CODIGO := _cCodigo
		endif
		
		for nCntFor2 := 1 to Len(_aAuxAHeader)
			// Campo nao ้ virtual ... 
			if _aAuxAHeader[nCntFor2,10] <> "V" .and. !(AllTrim(_aAuxAHeader[nCntFor2,2]) $ cNaoGrava)
				&(_aAuxAHeader[nCntFor2,2]) := _aAuxACols[nCntFor,nCntFor2]
			endif
		next nCntFor2

		// Indica que o registro nao foi exportado
		VST->VST_EXPPEC := "0"
		VST->VST_EXPSRV := "0"
		
		// Grava Marca do Veiculo quando nao for inconveniente manual
		if !Empty(VST->VST_GRUINC) .and. !Empty(VST->VST_CODINC)
			VST->VST_CODMAR := _cCodMar		
		endif
		
		If lChassi
			VST->VST_CHASSI := _cChassi
		EndIf
		
		MsUnlock()  
	
	//	Registro Excluido da ACols
	else  
	
		// Se tiver sequencial, o registro esta gravado na base
		if !Empty(_aAuxACols[nCntFor,nPosSeq])
		   
			dbSelectArea("VST")
			dbSetOrder(1)
			If VST->(dbSeek(xFilial("VST") + _cTpReg + _cCodigo + _aAuxACols[nCntFor,nPosSeq] ))
				RecLock("VST",.f.,.t.)
				VST->(dbDelete())
				MsUnLock()
			endif
			
		endif
		
	endif
next nCntFor
DBSelectArea("VST")
dbGoTop()

RestArea(oArea)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM420IMPINC     บAutor ณ Takahashi    บ Data ณ  15/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa inconveniente de um tipo de registro para outro    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ _cTpOrig  = Tipo de Registro Origem                        บฑฑ
ฑฑบ          ณ _cNumOrig = Codigo do Registro de Origem                   บฑฑ
ฑฑบ          ณ _cSeqOrig = Sequencia do Inconveniente do Orcamento        บฑฑ
ฑฑบ          ณ _cTpDest  = Tipo de Registro Destino                       บฑฑ
ฑฑบ          ณ _cNumDest = Codigo do Registro de Destino                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Sequencia do inconveniente criado                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM420IMPINC(_cTpOrig, _cNumOrig, _cSeqOrig, _cTpDest, _cNumDest)
Local aIncOrig  // Informacoes do Inconveniente de Origem  
Local aIncDest  // Informacoes do Inconveniente de Destino 
Local oAlias := GetArea()

if empty(_cSeqOrig)
	return ""
endif
                                                             
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConsulta informacoes do Inconveniente de Origem ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aIncOrig := OM420CONSINC( _cTpOrig, _cNumOrig, _cSeqOrig )
if Empty(aIncOrig[4])
	return ""
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o Inconveniente ja esta cadastrado para o Codigo Destino ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if !empty(aIncOrig[1]) .and. !empty(aIncOrig[2]) 
	// Procura por grupo e codigo
	aIncDest := OM420CONSINC( _cTpDest, _cNumDest,, aIncOrig[1], aIncOrig[2] )
else 
	// Procura por descricao 
	aIncDest := OM420CONSINC( _cTpDest, _cNumDest,,,, aIncOrig[3] )
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe a Seq. retornada estiver em branco, o Inconv. nao esta cadastradoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if empty(aIncDest[4]) 
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGera um sequencial para o Inconvenienteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aIncDest[4] := OM420NUMSEQ(_cTpDest,_cNumDest)
	
	dbSelectArea("VST")
	RecLock("VST",.T.)
	VST->VST_FILIAL := xFilial("VST")
	VST->VST_TIPO   := _cTpDest
	VST->VST_CODIGO := _cNumDest
	VST->VST_SEQINC := aIncDest[4] // Sequencia do Inconveniente para a OS
	VST->VST_GRUINC := aIncOrig[1] // Grupo do Inconveniente do Orcamento
	VST->VST_CODINC := aIncOrig[2]
	VST->VST_DESINC := aIncOrig[3]
	VST->VST_CODMAR := aIncOrig[5]
	If ( VST->(FieldPos("VST_CHASSI")) > 0 )
		VST->VST_CHASSI := aIncOrig[6]
	EndIf
	// Indica que o registro nao foi exportado
	VST->VST_EXPPEC := "0"
	VST->VST_EXPSRV := "0"

	MsUnLock()
	VST->(dbGoTop()) // Desposiciona para Liberar o Lock do Registro 
	
endif                    

RestArea( oAlias )

Return aIncDest[4]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM420FATPAR     บAutor ณ Takahashi    บ Data ณ 26/01/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Tipo de Tempo e Cliente que devera ser utilizado บฑฑ
ฑฑบ          ณ como sugestao na exportacao do agendamento                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ _cTp     = Tipo de Registro ("P"=Peca / "S"=Servico)       บฑฑ
ฑฑบ          ณ _cCodMar = Marca do Veiculo                                บฑฑ
ฑฑบ          ณ _cGruInc = Grupo de Inconveniente                          บฑฑ
ฑฑบ          ณ _cCodInc = Codigo de Inconveniente                         บฑฑ
ฑฑบ          ณ _cCodCli = Codigo do Cliente                               บฑฑ
ฑฑบ          ณ _cLojCli = Loja do Cliente                                 บฑฑ
ฑฑบ          ณ _cChassi = Chassi do Veํculo                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ [01] = Tipo de Tempo                                       บฑฑ
ฑฑบ          ณ [02] = Cliente                                             บฑฑ
ฑฑบ          ณ [03] = Loja                                                บฑฑ
ฑฑบ          ณ [04] = Tipo do Retorno - 1 = Cliente                       บฑฑ
ฑฑบ          ณ                          2 = Fabrica                       บฑฑ
ฑฑบ          ณ                          3 = Concessionaria                บฑฑ
ฑฑบ          ณ                          4 = Outros                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM420FATPAR(_cTp, _cCodMar, _cGruInc, _cCodInc, _cCodCli, _cLojCli, _cChassi)

Local aRetorno := { "" , "" , "" , 0 }
Local lConces // Controla se vai ser faturado para a propria concessionaria 
Local aArea
Local aSM0
Local nContSM0

aArea := sGetArea(aArea,Alias())
aArea := sGetArea(aArea,"VE4")
aArea := sGetArea(aArea,"VV1")
aArea := sGetArea(aArea,"VVK")
aArea := sGetArea(aArea,"VOI")
aArea := sGetArea(aArea,"SA1")

dbSelectArea("VSL")
dbSetOrder(1) // VSL_CODMAR+VSL_CODGRU+VSL_CODINC
if !dbSeek(xFilial("VSL") + _cCodMar + _cGruInc + _cCodInc)
	dbSelectArea("VSL")
	dbSetOrder(1) // VSL_CODMAR+VSL_CODGRU+VSL_CODINC
	if !dbSeek(xFilial("VSL") + Space(TamSX3("VV1_CODMAR")[1]) + _cGruInc + _cCodInc)
		return aRetorno
	endif 
Endif
// Peca sempre ้ o cliente que paga
if _cTp == "P"
	aRetorno[1] := VSL->VSL_TIPTEM
	aRetorno[2] := _cCodCli
	aRetorno[3] := _cLojCli
	aRetorno[4] := 1 // Cliente 

// Servicos 
elseif _cTp == "S"
	
	// Se o Tipo do Inconv. for NORMAL ou DEMAIS REVISOES .. 
	if VSL->VSL_TIPO $ "1/3" .OR. (GetNewPar("MV_MIL0006", " ") == 'JD' .AND. VSL->VSL_TIPO == "2")
		aRetorno[1] := VSL->VSL_TIPTSV
		aRetorno[2] := _cCodCli
		aRetorno[3] := _cLojCli
		aRetorno[4] := 1 // Cliente 

	// Se o Tipo do Inconv. for REVISAO, o TT e Fat par sera de acordo com os parametros do Inconv. 
	elseif VSL->VSL_TIPO == "2"

		// Posiciona Veiculo
		VV1->(dbSetOrder(2)) // VV1_CHASSI
		VV1->(dbSeek(xFilial("VV1")+_cChassi))

		// Se tiver gravado o codigo da concessionaria q vendeu o veiculo no VV1
		if !Empty(VV1->VV1_CODCON)
		
			// Procura a Concessionaria 
			VVK->(dbSetOrder(1)) // VVK_CODMAR+VVK_CODCON
			if !VVK->(dbSeek(xFilial("VVK")+_cCodMar+VV1->VV1_CODCON))
				MsgInfo(STR0020) // "Concessionแria nใo cadastrada"
			else
			
				// Verifica se a Concessionaria ้ a Fabricante ...
				VE4->(dbSetOrder(1)) // VE4_PREFAB+VE4_CGCFAB
				if VE4->(dbSeek(xFilial("VE4")+_cCodMar+VVK->VVK_CGCVEN))
					aRetorno[1] := VSL->VSL_TPFABR
					aRetorno[2] := VE4->VE4_CODFAB
					aRetorno[3] := VE4->VE4_LOJA
					aRetorno[4] := 2 // Fabrica
				else
					
					// Verifica se o veiculo foi vendido pela propria concessionaria 
					lConces := .f.
					If FindFunction("FWLoadSM0")
						aSM0 := FWLoadSM0()
						If aScan( aSM0 , {|x| x[18] ==  AllTrim(VVK->VVK_CGCVEN) }) <> 0
							lConces := .t.
							aRetorno[1] := VSL->VSL_TPCONC // Tipo de Tempo Concessionaria 
							aRetorno[4] := 3 // Concessionaria
						EndIf
					Else
						nRecSM0  := SM0->(Recno())
						DbSelectArea("SM0")
						DbGoTop()
						While !SM0->(Eof())
							if SM0->M0_CGC == AllTrim(VVK->VVK_CGCVEN)
								lConces := .t.
								aRetorno[1] := VSL->VSL_TPCONC // Tipo de Tempo Concessionaria 
								aRetorno[4] := 3 // Concessionaria
								exit
							endif
							SM0->(dbSkip())
						End
						SM0->(dbGoTo(nRecSM0))
					EndIf
					//

					// Se nao for concessionaria 
					if !lConces 
						aRetorno[1] := VSL->VSL_TPOUTR // Tipo de Tempo Outros 
						aRetorno[4] := 4 // Outros
					endif
					//

					// Procura o Codigo do Cliente da Concessionaria que fez a venda do Veiculo 
					SA1->(dbSetOrder(3)) // A1_CGC
					if !SA1->(dbSeek(xFilial("SA1")+VVK->VVK_CGCVEN))
						MsgInfo( STR0022 + CHR(13) + CHR(10) + STR0023 + ": " + Transform(VVK->VVK_CGCVEN,"@R 99.999.999/9999-99") )
					else
						aRetorno[2] := SA1->A1_COD
						aRetorno[3] := SA1->A1_LOJA
					endif

				endif
				//
			endif
		else
			MsgInfo(STR0021) // "Veํculo sem c๓digo de concessionaria que o vendeu. Verifique o Cadastro de Veํculos"
		endif
	endif
endif

sRestArea( aArea )

Return aRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM420SRVAD บAutor  ณ Takahashi         บ Data ณ  29/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se deve adicionar servicos a OS que esta sendo    บฑฑ
ฑฑบ          ณ exportada                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ _cNumOrc = Numero do Orcamento                             บฑฑ
ฑฑบ          ณ _cCodCli = Codigo do Cliente                               บฑฑ
ฑฑบ          ณ _cLojCli = Loja do Cliente                                 บฑฑ
ฑฑบ          ณ _cChaint = Chassi Interno                                  บฑฑ
ฑฑบ          ณ _nKM = Kilometragem do Veiculo                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM420SRVAD(_cNumOrc, _cCodCli, _cLojCli, _cChaint, _nKM)

Local cSQL
Local cALIASINC := GetNextAlias()
Local aTTCliente
Local aRet, aServ
Local cAuxChassi
Local aRetorno := {}
Local nCont
Local nCont2
Local cAuxMsg

cAuxChassi := FM_SQL("SELECT VV1_CHASSI FROM "+RetSQLName("VV1")+" WHERE VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1_CHAINT = '"+_cChaint+"' AND D_E_L_E_T_ = ' '")

cSQL := "SELECT VST_GRUINC, VST_CODINC, VST_SEQINC, VST_CODMAR, VSL_TIPTSV"
cSQL +=  " FROM " + RetSQLName("VST") + " VST JOIN " + RetSQLName("VSL") + " VSL ON VSL.VSL_FILIAL = '" + xFilial("VSL") + "' AND VSL.VSL_CODGRU = VST.VST_GRUINC AND VSL.VSL_CODINC = VST.VST_CODINC AND VSL.D_E_L_E_T_ = ' '"
cSQL += " WHERE VST.VST_FILIAL = '" + xFilial("VST") + "'"
cSQL +=   " AND VST.VST_TIPO = '1'" // Inconvenientes do Orcamento 
cSQL +=   " AND VST.VST_CODIGO = '" + _cNumOrc + "'"
cSQL +=   " AND VST.VST_GRUINC <> '" + Space(TamSx3("VST_GRUINC")[1]) + "' AND VST.VST_CODINC <> '" + Space(TamSx3("VST_CODINC")[1]) + "'"
cSQL +=   " AND VST.D_E_L_E_T_ = ' '"
cSQL +=   " AND VSL.VSL_TIPO = '2'" // Somente Primeira Revisao
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cALIASINC , .F., .T. )
(cALIASINC)->(DbgoTop())
Do while !(cALIASINC)->(Eof())

	aTTCliente := OM420FATPAR("S", ;
								(cALIASINC)->(VST_CODMAR),;
								(cALIASINC)->(VST_GRUINC),;
								(cALIASINC)->(VST_CODINC),;
								_cCodCli,;
								_cLojCli,; 
								cAuxChassi)

	aRet := OFIOM420( (cALIASINC)->(VST_GRUINC),;	// Grupo do Inconveniente
					  (cALIASINC)->(VST_CODINC),;	// Codigo do Inconveniente
					  _cChaint,;					// Chassi Interno do Veiculo
					  _nKM ,;						// Km do Veiculo
					  (cALIASINC)->(VSL_TIPTSV),;	// Tipo de Tempo
					  , ;							// Descricao do Inconveniente
					  .F. ,;						// (Parametro Obsoleto) - nao sera exibido mais nenhuma tela
					  ,;							// Tipo de Tempo de Servico
					  ,;                            // Indica se vai ser utilizado para cliente Considerado quando for inc. de 1ช Revisao
					  .F. ,;						// Indica se vai retornar os valores das pecas e dos servicos
					  ,;							// Indica a formula utilizada no Valor da Peca
					  ,;							// Indica o Codigo do Cliente para buscar o Valor da Hora do Servico
					  ,;							// Indica a Loja do Cliente para buscar o Valor da Hora do Servico
					  .T.,;                        	// Indica se mostra mensagem qdo inconveniente nao pode ser utilizado
					  aTTCliente[4] )				// Tipo de cliente para determinar Tipo de Servico de servicos de 1ช revisao 
	aServ := aRet[2]
	
	If Len(aServ) > 0
		cAuxMsg := ""
		If Empty(aTTCliente[1])
			cAuxMsg += STR0026 + CHR(13) + CHR(10) // "Nใo foi possํvel determinar o Tipo de Tempo de servi็o adicional do inconveniente."
		EndIf
		If Empty(aTTCliente[2]) .or. Empty(aTTCliente[3])
			cAuxMsg += STR0027 + CHR(13) + CHR(10) // "Nใo foi possํvel determinar o Faturar Para de servi็o adicional do inconveniente."
		EndIf
		If !Empty(cAuxMsg)
			MsgInfo(cAuxMsg + CHR(13) + CHR(10) + ;
					STR0028 + ": " + AllTrim(aServ[01,04]) + " / " + AllTrim(aServ[01,05]) + CHR(13) + CHR(10) +; // "Grupo/C๓digo Inconveniente"
					STR0029 + ": " + AllTrim(aServ[01,06]) )
			aRetorno := { {"","","",""} }	// Retorna dessa forma para para execucao do OFIXX001
			Exit
		EndIf
	EndIf
	//	
	
	For nCont := 1 to Len(aServ)
		AADD( aRetorno , Array(Len(aServ[nCont]) + 4 ) )
		
		aRetorno[nCont,1] := (cAliasINC)->VST_SEQINC
		aRetorno[nCont,2] := aTTCliente[1]
		aRetorno[nCont,3] := aTTCliente[2]
		aRetorno[nCont,4] := aTTCliente[3] 
		
		For nCont2 := 1 to Len(aServ[nCont])
			aRetorno[nCont,nCont2+4] := aServ[nCont,nCont2]
		Next nCont2
		
	Next nCont

	(cALIASINC)->(dbSkip())
End
(cALIASINC)->(dbCloseArea())
dbSelectArea("VST")

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM420CODMAR  บAutor  ณCarla Catiane F R  บ Data ณ 07/07/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se Codigo da marca associado ao grupo e codigo do   บฑฑ
ฑฑบ          ณ inconveniente.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ _cCodMar = Codigo da Marca                                 บฑฑ
ฑฑบ          ณ _cGruInc = Grupo do Inconveniente.                         บฑฑ
ฑฑบ          ณ _cCodInc = Codigo do Inconveniente.                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM420CODMAR(_cCodMar, _cGruInc, _cCodInc )

Local lRet   := .f.
Local cQuery := ""
Local aArea  := {}

aArea := sGetArea(aArea,Alias())
aArea := sGetArea(aArea,"VSK")

cQuery := " SELECT Count(*) "
cQuery += " FROM " + RetSqlName("VSK") + " VSK "
If !Empty(_cCodInc)
	cQuery += "INNER JOIN " + RetSqlName("VSL") + " VSL "
	cQuery += "		  ON VSL_FILIAL = '" + xFilial("VSL") + "' AND VSL_CODGRU = VSK_CODGRU AND 
	cQuery += "			  VSL_CODINC = '" + _cCodInc + "' AND VSL.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " WHERE VSK_FILIAL = '" + xFilial("VSK") + "' AND VSK_CODGRU = '" + _cGruInc + "' AND "
cQuery += " 	 ( VSK_CODMAR = '" + _cCodMar + "' OR VSK_CODMAR = '" + Space(TamSX3("VSK_CODMAR")[1]) + "') AND "
cQuery += "			VSK.D_E_L_E_T_ = ' '"

If FM_SQL( cQuery ) > 0
	lRet := .t.
EndIf

Return lRet
