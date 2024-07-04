#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FLUXOPRODUCAO.CH"

class GenericCod
	data cod
	Method New(codigo)
endclass

Method New(codigo) class GenericCod
	self:cod := AllTrim(codigo)
Return self	

class CodRefer
	data cod_chave_erp
	data cod_refer
	Method New(cod,refer)
endclass

Method New(cod,refer) class CodRefer
	self:cod_chave_erp	:= AllTrim(cod)
	self:cod_refer		:= AllTrim(refer)
Return self

class estruProduc	
	data cod_item_pai
	data refer_pai
	data cod_item_filho
	data refer_filho
	data qtd_pai
	data qtd_filho
	Method New()
endclass

Method New(codPai, codFilho) class estruProduc
	Local aAreaSB1 := SB1->(GetArea())
	
	self:cod_item_pai		:= AllTrim(codPai)
	self:refer_pai		:= ""
	self:cod_item_filho	:= AllTrim(codFilho)
	self:refer_filho		:= ""
	self:qtd_filho		:= SG1->G1_QUANT
	
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek( xFilial("SB1") + codPai ))
	
	self:qtd_pai	:= If(SB1->B1_QB == 0, 1, SB1->B1_QB)
	
	SB1->(RestArea(aAreaSB1))
Return self
	
class itemProduc
	data cod_chave_erp
	data des_item_erp
	data cod_refer
	data cod_un_med_erp
	data cod_depos_erp
	data cod_localiz
	data qti_tam_kanban
	data qti_estoq_segur
	data vli_tempo_setup
	data vli_tempo_ciclo
	data qti_lote_minimo
	data log_proces_ext
	Method New()
endclass

Method New() class itemProduc
	
	Local LoteMin	

	self:cod_chave_erp	:= AllTrim(SB1->B1_COD)
	self:des_item_erp		:= AllTrim(SB1->B1_DESC)
	self:cod_refer		:= ""
	self:cod_un_med_erp	:= AllTrim(SB1->B1_UM)	
	self:cod_depos_erp	:= AllTrim(SB1->B1_LOCPAD)
	self:cod_localiz		:= ""
	self:qti_tam_kanban	:= SB1->B1_LM
	self:qti_estoq_segur	:= SB1->B1_ESTSEG
	self:vli_tempo_setup	:= 0
	self:vli_tempo_ciclo	:= 0
	self:log_proces_ext	:= .F.
	
	//Lote Mínimo - Será o menor valor entre o Lote Minimo(B1_LM) e Lote Economico(B1_LE), exceto zero.
	LoteMin := SB1->B1_LM
	If LoteMin == 0 .Or. (SB1->B1_LE != 0 .And. SB1->B1_LE < LoteMin)
		LoteMin := SB1->B1_LE
	EndIf	
	
	self:qti_lote_minimo := LoteMin
Return self

class ferramProduc
	data itens
	data cod_chave_erp
	data des_ferram
	Method New()
endclass

Method New() class ferramProduc
	self:itens				:= {}
	self:cod_chave_erp	:= AllTrim(SH4->H4_CODIGO)
	self:des_ferram		:= AllTrim(SH4->H4_DESCRI)
Return self

class ctProduc
	data celulas
	data cod_chave_erp
	data des_ct_erp
	Method New()
endclass

Method New() class ctProduc
	self:celulas			:= {}
	self:cod_chave_erp	:= AllTrim(SH1->H1_CODIGO)
	self:des_ct_erp		:= AllTrim(SH1->H1_DESCRI)
Return self

class celulaProduc
	data itens
	data cod_chave_erp
	data des_cel
	Method New()
endclass

Method New() class celulaProduc
	self:itens				:= {}
	self:cod_chave_erp	:= AllTrim(SHB->HB_COD)
	self:des_cel			:= AllTrim(SHB->HB_NOME)
Return self

class errosPorItem
	data item
	data msg
	Method New(item,msg)	
endclass
Method New(item,msg) class errosPorItem
	self:item := item
	self:msg := msg
Return self
	
class fluxoProduc
	data itens
	data celulas
	data centros_trab
	data estrutura
	data ferramentas
	Method New()
	Method AddItem(item)
	Method AddEstrutura(estrut)
	Method AddItemFerram(item, ferram)
	Method AddItemCel(item, cel)
	Method AddCelCT(cel, ct)
endclass

Method New() class fluxoProduc
	self:itens			:= {}
	self:celulas		:= {}
	self:centros_trab	:= {}
	self:estrutura	:= {}
	self:ferramentas	:= {}
Return self

Method AddItem(item) class fluxoProduc
	Local nI
	
	For nI := 1 To Len(self:itens)
		If self:itens[nI]:cod_chave_erp == item:cod_chave_erp .And. self:itens[nI]:cod_refer == item:cod_refer 
			Return
		EndIf
	Next
	
	aAdd(self:itens, item)
Return	

Method AddEstrutura(estrut) class fluxoProduc
	Local nI

	For nI := 1 To Len(self:estrutura)
		If self:estrutura[nI]:cod_item_pai == estrut:cod_item_pai ;
		   .And. ;
		   self:estrutura[nI]:cod_item_filho == estrut:cod_item_filho ;
		   .And. ;
		   self:estrutura[nI]:refer_pai == estrut:refer_pai ;
		   .And. ;
		   self:estrutura[nI]:refer_filho == estrut:refer_filho 
			Return
		EndIf
	Next

	aAdd(self:estrutura, estrut)
Return	

Method AddItemFerram(item, ferram) class fluxoProduc

	Local nI
	Local lExiste := .F.

	For nI := 1 To Len(self:ferramentas)
	
		If(self:ferramentas[nI]:cod_chave_erp == ferram:cod_chave_erp)
			ferram = self:ferramentas[nI]
			lExiste := .T.
			Exit
		EndIf 
	
	Next
	
	If lExiste
		For nI := 1 To Len(ferram:itens)
			If(ferram:itens[nI]:cod_chave_erp == item:cod_chave_erp .And. ferram:itens[nI]:cod_refer == item:cod_refer)
				Return
			EndIf 	
		Next
	EndIf
	
	aAdd( ferram:itens, CodRefer():New( item:cod_chave_erp, item:cod_refer ) )
	
	If !lExiste
		aAdd(self:ferramentas, ferram)
	EndIf
	
Return

Method AddItemCel(item, cel) class fluxoProduc

	Local nI
	Local lExiste := .F.

	For nI := 1 To Len(self:celulas)
	
		If(self:celulas[nI]:cod_chave_erp == cel:cod_chave_erp)
			cel = self:celulas[nI]
			lExiste := .T.
			Exit
		EndIf 
	
	Next
	
	If lExiste
		For nI := 1 To Len(cel:itens)
			If(cel:itens[nI]:cod_chave_erp == item:cod_chave_erp .And. cel:itens[nI]:cod_refer == item:cod_refer)
				Return
			EndIf 	
		Next
	EndIf
	
	aAdd( cel:itens, CodRefer():New( item:cod_chave_erp, item:cod_refer ) )
	
	If !lExiste
		aAdd(self:celulas, cel)
	EndIf
	
Return

Method AddCelCT(cel, ct) class fluxoProduc

	Local nI
	Local lExiste := .F.
 
	For nI := 1 To Len(self:centros_trab)
	
		If(self:centros_trab[nI]:cod_chave_erp == ct:cod_chave_erp)
			ct = self:centros_trab[nI]
			lExiste := .T.
			Exit
		EndIf 
	
	Next
	
	If lExiste
		For nI := 1 To Len(ct:celulas)
			If(ct:celulas[nI]:cod == cel:cod_chave_erp)
				Return
			EndIf 	
		Next
	EndIf
	
	aAdd( ct:celulas, GenericCod():New(cel:cod_chave_erp) )
	
	If !lExiste
		aAdd(self:centros_trab, ct)
	EndIf

Return

WSRESTFUL flowProduction DESCRIPTION "Busca fluxo de produção do item para o Ekanban"
	 
	WSDATA estab AS char
	WSDATA datCorte AS char	
	WSDATA codItem AS char
	 
	WSMETHOD GET DESCRIPTION "Fluxo de Produção" WSSYNTAX "/flowProduction"
 
END WSRESTFUL

WSMETHOD GET WSRECEIVE estab, datCorte, codItem WSSERVICE flowProduction

	Local fluxo		:= fluxoProduc():New()
	Local empFilial	:= {}
	Local erros := {}
	local cont
	local msg

	DEFAULT self:estab := nil, self:datCorte := nil, self:codItem := nil
	If self:estab == nil ;
		.or. ;
		self:datCorte == nil ;
		.or. ;
		self:codItem == nil
		
		::SetContentType("application/json")	 
		::SetResponse(FWJsonSerialize(fluxo,.F.,.F.))
		return .T.
	endif
	OpenSM0()
	SM0->(dbGotop())

	//Grupo de Empresa
	aAdd(empFilial,SubStr(self:estab,1,Len(SM0->M0_CODIGO)))
	//Empresa + Unidade de negocio + Filial
	aAdd(empFilial,SubStr(self:estab,2 + Len(SM0->M0_CODIGO) ))

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(empFilial[1], empFilial[2])

	BuscaInfoFluxo(fluxo, self:codItem, self:datCorte, erros, self:codItem)
	if Len(erros) == 0
		::SetContentType("application/json")	 
		::SetResponse(FWJsonSerialize(fluxo,.F.,.F.))
	Else
		msg := ''
		For cont := 1 To Len(erros)
			msg += erros[cont]:msg + chr(13) + chr(10) 
		Next	
		SetRestFault(400, msg)
		return .F.
	EndIf
Return .T.

Static Function BuscaInfoFluxo(fluxo, cod_item, data_corte, listaErros, itemFinal)

	Local item
	Local filhosItem := {}
	Local nI
	Local lExiste
	Local msgValid
	Local celulaItemGerada := .F.
	Local roteiroEncontrado		
	Local msgCont := 0

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek( xFilial("SB1") + cod_item )) ;
	   .And. ;
	   AllTrim(SB1->B1_COD) == AllTrim(cod_item)

		item := itemProduc():New()
		fluxo:AddItem( item )
		createItemStructure(SB1->B1_COD, filhosItem, data_corte)

		If Len(filhosItem) == 0

			If AllTrim(cod_item) == AllTrim(itemFinal)
				msgValid := STR0009
				/*
				O Item final deve conter ao menos um item na estrutura
				*/
				aadd(listaErros, errosPorItem():New(cod_item, msgValid))  
			EndIF

			return .T.
		EndIf

		roteiroEncontrado := If(empty(SB1->B1_OPERPAD), bringAlternativeRoute(SB1->B1_COD), SB1->B1_OPERPAD)
		If Empty(roteiroEncontrado)
			defaultRoute := GetAnyValRot(SB1->B1_COD, data_corte)
		else
			defaultRoute := GetAnyValRot(SB1->B1_COD, data_corte, roteiroEncontrado)		
		endif
		
		dbSelectArea("SG2")
		SG2->(dbSetOrder(1))		
		If !Empty(defaultRoute) .And. SG2->(dbSeek(xFilial("SG2") + SB1->B1_COD + defaultRoute))
			celulaItemGerada := .F.
			While SG2->(! Eof()) ;
			      .And. ;
			      SG2->(G2_FILIAL + G2_PRODUTO + G2_CODIGO) == xFilial("SG2") + SB1->B1_COD + defaultRoute

				If isValidOperation(data_corte, SG2->G2_DTINI, SG2->G2_DTFIM, SG2->G2_TEMPAD)
				 	createToolsAtFlow(fluxo, item)
				 	if(!celulaItemGerada)
				 		celulaItemGerada := addCell(fluxo, item, SG2->G2_CTRAB)
				 	endif
				EndIf
				
				SG2->(dbSkip())
			End
		EndIf
				
		For nI := 1 To Len(filhosItem)
			dbSelectArea("SG1")
			SG1->( dbSetOrder(1) )
			SG1->( dbSeek(xFilial("SG1") + PadR(cod_item,TamSX3("B1_COD")[1], " ") + filhosItem[nI]) )
			fluxo:AddEstrutura( estruProduc():New(cod_item, filhosItem[nI]) )
			BuscaInfoFluxo(fluxo, filhosItem[nI], data_corte, listaErros, itemFinal)
		Next
	endif
return .T. 

static function bringAlternativeRoute(cod_item)

	dbSelectArea("SG2")
	dbSetOrder(1)
		
	if dbseek(xFilial("SG2") + cod_item + '01') .And. AllTrim(SG2->G2_CODIGO) == "01"
		return "01"
	endif

return ""

static function GetAnyValRot(cod_item, dat_corte, roteiro)
	default roteiro := ''
	
	dbSelectArea("SG2")
	dbSetOrder(1)	
	dbseek(xFilial("SG2") + cod_item + roteiro)
	
	while SG2->(! Eof()) ; 
				.and. ;
				 SG2->G2_filial == xFilial("SG2") ;
				 .and. ;
				 sg2->g2_produto == cod_item ;
				 .and. ;
				 (roteiro == '' .or. sg2->g2_codigo == roteiro)
				 							 
		if isValidOperation(dat_corte, sg2->g2_dtini, sg2->g2_dtfim,sg2->g2_tempad) ;   
			.and. ;
			!empty(alltrim(sg2->g2_ctrab)) ;
			.and. ;
			workCenterHasResources(sg2->g2_ctrab)
			return SG2->G2_CODIGO
		endif			
		SG2->(dbskip())				 
	end
return ""

static function constraintDates (dat_Corte, dataIni, dataFim)
	local validStart
	local validEnd
	
	validStart := if(empty(allTrim(dtos(dataIni))), .T., dataIni <= stod(dat_Corte)) 
	validEnd := if(empty(allTrim(dtos(dataFim))), .T., dataFim >= stod(dat_Corte))

return (validStart .and. validEnd)

static function isValidOperation(dat_corte, dtIniRoteiro, dtFimRoteiro, tempoPadraoOperac)
	local retorno := .F.
	retorno := constraintDates(dat_corte, dtIniRoteiro, dtFimRoteiro) ;
				.and. ;
				tempoPadraoOperac > 0 
return retorno

static function createToolsAtFlow(fluxo, item)
	If !Empty(SG2->G2_FERRAM)
		dbSelectArea("SH4")
		SH4->(dbSetOrder(1))
		If SH4->(dbSeek( xFilial("SH4") + SG2->G2_FERRAM ))
		
			fluxo:AddItemFerram(item, ferramProduc():New())
			
		EndIf
		SH4->(dbSkip())
	EndIf
return .T.

static function createItemStructure(cod_item, filhosItem, data_corte)
	//Verifica se o item possui estrutura(se é fabricado)
	local lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
	Local cRevAtu		:= IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )
	
	dbSelectArea("SG1")
	SG1->( dbSetOrder(1) )
	SG1->( dbSeek( xFilial("SG1") + cod_item))
	
	While SG1->(!Eof()) .And. SG1->(G1_FILIAL + G1_COD) == xFilial("SG1") + cod_item
		
		If constraintDates(data_corte, SG1->G1_INI, SG1->G1_FIM) ;
		   .And. ;
		   cRevAtu >= SG1->G1_REVINI .And. cRevAtu <= SG1->G1_REVFIM
			aAdd(filhosItem,SG1->G1_COMP)
		EndIf
		SG1->(dbSkip())
	End
return .T.

function getCTByCel(celula)
	local CTList := {}
	
	dbSelectArea("SH1")
	dbSetOrder(4)	
	dbseek(xFilial("SH1") + celula)
	while SH1->(! Eof()) ;
		  .and. ;
		   SH1->h1_filial == xFilial("SH1") ; 
		  .and. ;
		   allTrim(sh1->h1_ctrab) == alltrim(celula)
	
		aadd(CTList, ctProduc():New())
		SH1->(dbSkip())
	End
return CTList

static function workCenterHasResources(cod_ctrab)
return Len(getCTByCel(cod_ctrab)) > 0

static function addCell(fluxo, item, centroTrab)

	Local celula
	local ctList	
	local cont

	dbSelectArea("SHB")
	SHB->(dbSetOrder(1))
	If SHB->(dbSeek( xFilial("SHB") + centroTrab))  

		celula := celulaProduc():New()
		item:vli_tempo_setup := (SG2->G2_SETUP * 3600000)
		item:vli_tempo_ciclo := (SG2->G2_TEMPAD * 3600000)
		
		If SG2->G2_LOTEPAD != 0
			item:vli_tempo_ciclo := item:vli_tempo_ciclo / SG2->G2_LOTEPAD
		EndIf
		fluxo:AddItemCel(item, celula)
		ctList := getCTByCel(SHB->HB_COD)
		For cont := 1 To Len(ctList)
			fluxo:AddCelCt(celula, ctList[cont])
		Next		
		return .T.
	EndIf
return .F.
