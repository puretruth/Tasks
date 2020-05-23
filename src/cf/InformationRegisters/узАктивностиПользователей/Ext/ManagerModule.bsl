﻿
//+ #201 Иванов А.Б. 2020-05-23 Изменения от Дениса Урянского @d-hurricane
// См. УправлениеДоступомПереопределяемый.ПриЗаполненииСписковСОграничениемДоступа.
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	
	Ограничение.Текст =
	"РазрешитьЧтение
	|ГДЕ
	|	ВЫБОР 
	|		КОГДА ТипЗначения(СсылкаНаОбъект) = Тип(Справочник.узЗадачи)
	|			ТОГДА ЧтениеОбъектаРазрешено(ВЫРАЗИТЬ(СсылкаНаОбъект КАК Справочник.узЗадачи))
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ
	|;
	|РазрешитьИзменениеЕслиРазрешеноЧтение
	|ГДЕ
	|	ВЫБОР 
	|		КОГДА ТипЗначения(СсылкаНаОбъект) = Тип(Справочник.узЗадачи)
	|			ТОГДА ЧтениеОбъектаРазрешено(ВЫРАЗИТЬ(СсылкаНаОбъект КАК Справочник.узЗадачи))
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ";
	
КонецПроцедуры //- #201 Иванов А.Б. 2020-05-23 Изменения от Дениса Урянского @d-hurricane

Процедура ДобавитьАктивностьПользователя(Источник, ДопПараметры,Отказ) Экспорт
	Если Отказ Тогда
		Возврат;
	Конецесли;
	
	Если Константы.узРегистрироватьАктивностьПользователей.Получить() = Ложь Тогда
		Возврат;
	Конецесли;
	
	ТипЗнчИсточник = ТипЗнч(Источник);
	
	Если ТипЗнчИсточник = Тип("СправочникОбъект.узЗадачи") Тогда
		ДобавитьАктивностьПользователя_Задачи(Источник, ДопПараметры,Отказ);
	ИначеЕсли ТипЗнчИсточник = Тип("СправочникОбъект.узВопросыОтветы") Тогда
		ДобавитьАктивностьПользователя_ВопросыОтветы(Источник, ДопПараметры,Отказ);
	ИначеЕсли ТипЗнчИсточник = Тип("СправочникОбъект.узИсторияКонфигураций") Тогда
		ДобавитьАктивностьПользователя_ИсторияКонфигураций(Источник, ДопПараметры,Отказ);		
	ИначеЕсли ТипЗнчИсточник = Тип("ДокументОбъект.узВыпускРелиза") Тогда
		ДобавитьАктивностьПользователя_ВыпускРелиза(Источник, ДопПараметры,Отказ);
	Иначе
		ВызватьИсключение "Ошибка! нет алгоритма для регистрации активности пользователя";
	Конецесли;
	
КонецПроцедуры 

Процедура ДобавитьАктивностьПользователя_ИсторияКонфигураций(Источник, ДопПараметры,Отказ)
	#Если Тромбон тогда
		Источник = Справочники.узИсторияКонфигураций.СоздатьЭлемент();
	#Конецесли
	ВидыСобытий_ИзмененаКонфигурация = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ИзмененаКонфигурация");
	
	пДатаАктивности = Источник.ДатаВерсии;
	пСсылкаНаОбъект = Источник.Ссылка;
	пПользователь = Источник.Пользователь;
	
	ПредставлениеЗадачи	= "";	
	пЗадача = Источник.Задача;
	Если ЗначениеЗаполнено(пЗадача) Тогда
		ПредставлениеЗадачи = "#" + Формат(пЗадача.Код,"ЧГ=0") + " " + пЗадача;
	Конецесли;
	
	пОписание = "" + ВидыСобытий_ИзмененаКонфигурация;
	Если ЗначениеЗаполнено(пЗадача) Тогда
		пОписание = "" + ВидыСобытий_ИзмененаКонфигурация + " по задаче " + ПредставлениеЗадачи; 
	Конецесли;
	
	НаборЗаписей = РегистрыСведений.узАктивностиПользователей.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.СсылкаНаОбъект.Установить(пСсылкаНаОбъект);
	НаборЗаписей.Очистить();
	
	Запись = НаборЗаписей.Добавить();
	Запись.ДатаАктивности = пДатаАктивности;
	Запись.СсылкаНаОбъект = пСсылкаНаОбъект;
	Запись.Пользователь = пПользователь;
	Запись.ВидСобытия = ВидыСобытий_ИзмененаКонфигурация;			
	Запись.Описание = пОписание;
	Запись.ДеньАктивности = НачалоДня(пДатаАктивности);
	
	НаборЗаписей.Записать();
КонецПроцедуры 

Процедура ДобавитьАктивностьПользователя_ВыпускРелиза(Источник, ДопПараметры,Отказ)
	#Если Тромбон тогда
		Источник = Документы.узВыпускРелиза.СоздатьДокумент();
	#Конецесли
	ТЗСобытия = ДопПараметры.ТЗСобытия;
	
	НомерРелиза	= "" + Источник.НомерРелиза;
	
	ВидыСобытий_СозданДокументВыпускРелиза = ПредопределенноеЗначение("Перечисление.узВидыСобытий.СозданДокументВыпускРелиза");
	ВидыСобытий_ПроведенДокументВыпускРелиза = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ПроведенДокументВыпускРелиза");
	
	МассивВидовСобытияДляРегистрацииАктивности = Новый Массив();
	МассивВидовСобытияДляРегистрацииАктивности.Добавить(ВидыСобытий_СозданДокументВыпускРелиза);
	МассивВидовСобытияДляРегистрацииАктивности.Добавить(ВидыСобытий_ПроведенДокументВыпускРелиза);
	
	Для каждого СтрокаТЗСобытия из ТЗСобытия цикл
		пВидСобытия = СтрокаТЗСобытия.ВидСобытия;
		Если МассивВидовСобытияДляРегистрацииАктивности.Найти(пВидСобытия) = Неопределено Тогда
			Продолжить;
		Конецесли;
		
		МенеджерЗаписи = РегистрыСведений.узАктивностиПользователей.СоздатьМенеджерЗаписи();
		
		МенеджерЗаписи.ДатаАктивности = ТекущаяДата();
		МенеджерЗаписи.ДеньАктивности = НачалоДня(МенеджерЗаписи.ДатаАктивности);
		МенеджерЗаписи.Пользователь = Пользователи.ТекущийПользователь();
		МенеджерЗаписи.СсылкаНаОбъект = Источник.Ссылка;
		МенеджерЗаписи.ВидСобытия = пВидСобытия;
		
		МенеджерЗаписи.Описание = "" + пВидСобытия + " НомерРелиза " + НомерРелиза; 
		МенеджерЗаписи.Записать();
	Конеццикла;
	
КонецПроцедуры 

Процедура ДобавитьАктивностьПользователя_ВопросыОтветы(Источник, ДопПараметры,Отказ)
	#Если Тромбон тогда
		Источник = Справочники.узВопросыОтветы.СоздатьЭлемент();
	#Конецесли
	ТЗСобытия = ДопПараметры.ТЗСобытия;
	
	ПредставлениеЗадачи	= "";
	пЗадача = Источник.Задача;
	Если ЗначениеЗаполнено(пЗадача) Тогда
		ПредставлениеЗадачи = "#" + Формат(пЗадача.Код,"ЧГ=0") + " " + пЗадача;
	Конецесли;
	
	ВидыСобытий_ДобавленВопрос = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ДобавленВопрос");
	ВидыСобытий_ЗакрытВопрос = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ЗакрытВопрос");
	
	МассивВидовСобытияДляРегистрацииАктивности = Новый Массив();
	МассивВидовСобытияДляРегистрацииАктивности.Добавить(ВидыСобытий_ДобавленВопрос);
	МассивВидовСобытияДляРегистрацииАктивности.Добавить(ВидыСобытий_ЗакрытВопрос);
	
	Для каждого СтрокаТЗСобытия из ТЗСобытия цикл
		пВидСобытия = СтрокаТЗСобытия.ВидСобытия;
		Если МассивВидовСобытияДляРегистрацииАктивности.Найти(пВидСобытия) = Неопределено Тогда
			Продолжить;
		Конецесли;
		
		МенеджерЗаписи = РегистрыСведений.узАктивностиПользователей.СоздатьМенеджерЗаписи();
		
		МенеджерЗаписи.ДатаАктивности = ТекущаяДата();
		МенеджерЗаписи.ДеньАктивности = НачалоДня(МенеджерЗаписи.ДатаАктивности);
		МенеджерЗаписи.Пользователь = Пользователи.ТекущийПользователь();
		МенеджерЗаписи.СсылкаНаОбъект = Источник.Ссылка;
		МенеджерЗаписи.ВидСобытия = пВидСобытия;
		
		Если ЗначениеЗаполнено(пЗадача) Тогда
			МенеджерЗаписи.Описание = "" + пВидСобытия + " к задаче " + ПредставлениеЗадачи; 
			Если пВидСобытия = ВидыСобытий_ЗакрытВопрос Тогда
				МенеджерЗаписи.Описание = "" + пВидСобытия + " по задаче " + ПредставлениеЗадачи; 
			Конецесли;
		Иначе
			МенеджерЗаписи.Описание = "" + пВидСобытия;	
		Конецесли;
		МенеджерЗаписи.Записать();
	Конеццикла;
	
КонецПроцедуры 

Процедура ДобавитьАктивностьПользователя_Задачи(Источник, ДопПараметры,Отказ)
	#Если Тромбон тогда
		Источник = Справочники.узЗадачи.СоздатьЭлемент();
	#Конецесли
	
	СобытияВИстории = ДопПараметры.СобытияВИстории;
	
	СтарыйСтатус = СобытияВИстории.СтарыйСтатус;
	НовыйСтатус = Источник.Статус;
	
	РегистрироватьАктивность = ПолучитьРегистрироватьАктивность_Задачи(СтарыйСтатус,НовыйСтатус);
	
	Если НЕ РегистрироватьАктивность Тогда
		Возврат;
	Конецесли;
	
	ТЗСобытияВИсторииДляУведомлений = СобытияВИстории.ТЗСобытияВИсторииДляУведомлений;
	
	ВидыСобытий_ДобавленаЗадача = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ДобавленаЗадача");
	ВидыСобытий_ИзменениеСтатуса = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ИзменениеСтатуса");
	ВидыСобытий_ДобавленКомментарий = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ДобавленКомментарий");
	
	МассивВидовСобытияДляРегистрацииАктивности = Новый Массив();
	МассивВидовСобытияДляРегистрацииАктивности.Добавить(ВидыСобытий_ДобавленаЗадача);
	МассивВидовСобытияДляРегистрацииАктивности.Добавить(ВидыСобытий_ИзменениеСтатуса);
	МассивВидовСобытияДляРегистрацииАктивности.Добавить(ВидыСобытий_ДобавленКомментарий);
	
	Для каждого СтрокаТЗСобытияВИсторииДляУведомлений из ТЗСобытияВИсторииДляУведомлений цикл
		пВидСобытия = СтрокаТЗСобытияВИсторииДляУведомлений.ВидСобытия;
		Если МассивВидовСобытияДляРегистрацииАктивности.Найти(пВидСобытия) = Неопределено Тогда
			Продолжить;
		Конецесли;
		
		МенеджерЗаписи = РегистрыСведений.узАктивностиПользователей.СоздатьМенеджерЗаписи();
		
		МенеджерЗаписи.ДатаАктивности = ТекущаяДата();
		МенеджерЗаписи.ДеньАктивности = НачалоДня(МенеджерЗаписи.ДатаАктивности);
		МенеджерЗаписи.Пользователь = Пользователи.ТекущийПользователь();
		МенеджерЗаписи.СсылкаНаОбъект = Источник.Ссылка;
		МенеджерЗаписи.ВидСобытия = пВидСобытия;
		
		ПредставлениеЗадачи = "#" + Формат(Источник.Код,"ЧГ=0") + " " + МенеджерЗаписи.СсылкаНаОбъект;
		МенеджерЗаписи.Описание = "" + пВидСобытия + " " + ПредставлениеЗадачи; 
		Если пВидСобытия = ВидыСобытий_ДобавленКомментарий Тогда
			МенеджерЗаписи.Описание = "" + пВидСобытия + " к задаче " + ПредставлениеЗадачи; 
		ИначеЕсли пВидСобытия = ВидыСобытий_ИзменениеСтатуса Тогда
			МенеджерЗаписи.Описание = "Новый статус ["+НовыйСтатус+"] у задачи " + ПредставлениеЗадачи; 
		Конецесли;
		МенеджерЗаписи.Записать();
	Конеццикла;
	
КонецПроцедуры 

Функция ПолучитьРегистрироватьАктивность_Задачи(СтатусИсточник,СтатусПриемник) 
	пРегистрироватьАктивность = Истина;
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	узНастройкиДляСтатусов.СтатусИсточник,
	|	узНастройкиДляСтатусов.СтатусПриемник,
	|	узНастройкиДляСтатусов.НеРегистрироватьАктивность
	|ИЗ
	|	РегистрСведений.узНастройкиДляСтатусов КАК узНастройкиДляСтатусов
	|ГДЕ
	|	узНастройкиДляСтатусов.СтатусИсточник = &СтатусИсточник
	|	И узНастройкиДляСтатусов.СтатусПриемник = &СтатусПриемник";
	
	Запрос.УстановитьПараметр("СтатусИсточник", СтатусИсточник);
	Запрос.УстановитьПараметр("СтатусПриемник", СтатусПриемник);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Если Выборка.НеРегистрироватьАктивность Тогда
			пРегистрироватьАктивность = Ложь;	
		Конецесли;
	КонецЦикла;
	
	Возврат пРегистрироватьАктивность;
КонецФункции 