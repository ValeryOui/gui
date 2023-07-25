local component = require("component")
local gpu = component.gpu
local ae2 = component.me_controller 
local mei = component.me_interface 
local gui = require("gui")
local event = require("event")
local ttf = require("tableToFile")
local io = require("io")
local unicode = require("unicode")
local serialization = require("serialization")
local pim = component.pim


function imagefromString(pictureString)
	local picture = {
		tonumber("0x" .. unicode.sub(pictureString, 1, 2)),
		tonumber("0x" .. unicode.sub(pictureString, 3, 4)),
	}

	for i = 5, unicode.len(pictureString), 7 do
		table.insert(picture, tonumber("0x" .. unicode.sub(pictureString, i, i + 1)))
		table.insert(picture, tonumber("0x" .. unicode.sub(pictureString, i + 2, i + 3)))
		table.insert(picture, tonumber("0x" .. unicode.sub(pictureString, i + 4, i + 5)) / 255)
		table.insert(picture, unicode.sub(pictureString, i + 6, i + 6))
	end

	return picture
end


local checkPimPlayer, db, logs, infoButton
local CHEST_PUSH_SIDE = 'DOWN'
local CHEST_PULL_SIDE = 'UP'
local playersPath = "/config.txt"
local logsPath = "/logs.txt"
local depositListStrings, depositListData, itemListStrings, itemListData, pages = {}, {}, {}, {}, {}
local depositListChoose, buyListChoose, curPage = 1, 1, 1

local prgName = "Store v1.0 by LIMI_np"


------------ Database ------------------------------------


function loadFile(name, tbl) 
  local file = io.open(name, "r")
  tbl = serialization.unserialize(file:read("*a")) or {}
  file:close()
end
function saveFile(name, tbl) 
  local file = io.open(name, "w")
  file:write(serialization.serialize(tbl))
  file:close()
end

function saveAll() saveFile(playersPath, db) end
function loadAll() 
  local file = io.open(playersPath, "r")
  db = serialization.unserialize(file:read("*a")) or {}
  file:close()
end

function saveLogs() saveFile(logsPath, logs) end
function loadLogs() 
  local file = io.open(logsPath, "r")
  if not file then logs = {} return  end
  
  logs = serialization.unserialize(file:read("*a")) or {}
  file:close()
end

function addLog(row)
  table.insert(logs, row)
  saveLogs()
end

function getPlayerMoney(uniqueName)
  if not db[uniqueName] then
    db[uniqueName] = 0
    saveAll(db)
  end

  return db[uniqueName]
end
function setPlayerMoney(uniqueName, value)
  if not db[uniqueName] then
    db[uniqueName] = 0
  end
  addLog(string.format("%s изменено значение денег с %s на %s (value = %s)", pimPlayer, db[uniqueName], db[uniqueName] + value, value))
  db[uniqueName] = db[uniqueName] + value
  saveAll(db)
end

loadAll() 
loadLogs() 
saveAll() 
function PrintTable(tbl) for k,v in pairs(tbl) do print(k,v) end end
PrintTable(db)


-----------------------------------------------------------



------------------- Config --------------------------------


local itemConfig = {
	--Майнкрафт
	{uniqueID = "minecraft:cactus", id = "81", name = "Кактус", price = 0.03, image = "1010298100⢠298100⣤298000⣤298000⣤298000⣤297F00⣤298000⣤298000⣤297F00⣤297F00⣤297F00⣤298000⣤298000⣤298000⣤298000⣤298000⡄298000⢸7E8000⣽7E8000⢽7F8000⠠7E7F00⣻7F8000⠘557F00⡟557F00⠛558100⠛7F8100⠚7F8100⢓7E8000⣤557F00⡟558000⢸7F7F00⠀297F00⡇298100⢸7E8000⣾7E7F00⡄7E7F00⢠7E7F00⠛297F00⡟295300⣽2A5300⣯2A5500⠘2A7E00⢻558000⢫7E8000⡟295500⢣2A5500⠘7F8000⡢297F00⡇298000⢸297F00⡟298000⢻7E8100⣤7E8000⡇295500⡄2A5300⡞2A5300⣳535400⡐2A5300⡣297E00⠘7E8100⢢2A8100⣧558000⣤7E7F00⣼298000⡇297F00⢸295500⡔2A7E00⢠7E8000⣼7E7F00⢤558000⣤2A7E00⣤292A00⣼295300⡛295500⢠2A8100⣤7F8100⣷7F8100⡹7F8100⠃7E8000⣾298000⡇298100⢸808100⡭7F8100⡫7E8000⣾7F8000⠪7F8000⡂7E8000⢿7E7F00⣤558000⡤557F00⣼557F00⡟557F00⠛557E00⠛7E7F00⡧7E7F00⣼298000⡇297F00⢸7F7F00⠀7E7F00⢿7F8100⠛7F8100⡟558100⠛557F00⢻7F8100⢿7F8100⠟7E8000⡟295500⠃295400⣤2A5500⠘558100⢸7F8100⡎298000⡇298000⢸7E8000⡿7E7F00⡄297E00⡟295500⠃2A5300⣾2A5500⠘537F00⢻7E8000⣷7F8000⢁2A7F00⣧2A5300⣝2A5500⢣7E8000⣼7F8000⢢298000⡇298100⢸7F8100⣤7E8000⡟292A00⢬535400⠈535400⡰2A5300⢓2A5500⢠558100⣼7E8100⡟7E8000⣟558000⣧7F8000⡠7F8000⡠7E7F00⣯297F00⡇298000⢸7F8100⣼7E8100⣧297E00⣧295300⣻2A5500⢠2A7E00⣼7E8100⣤7F8100⠻7F8000⡣7E8000⣟7F8100⠛7F8100⣷2A7F00⡟297E00⠛298000⡇298000⢸7F8000⢠7E8000⢿7F8000⠊558000⣤558000⣤7E7F00⠄7E7F00⢣7E8000⣻7F8000⡠7F8000⢠7F8100⣧558100⡇295300⣽2A5400⡛297E00⡄298000⢸7F8000⢄2A7F00⡟2A5500⠛547E00⢻558100⠛558100⢻7F8100⡣7F8100⡻7E8000⡿538000⠃2A8000⢻558100⢻2A8000⣧558000⡼298100⡇298000⢸557F00⡇295300⣺535400⡬2A5300⡣295300⣷298000⠘7F7F00⠀7E7F00⣤558000⡇2A5400⣽295400⣇297E00⠘7E7F00⢸7E7F00⠄297F00⡇298100⢸7E8100⣇297E00⣧2A5300⢹295500⢣297E00⣤297F00⡟298000⢻557F00⢻558000⣥295500⡇295300⢟298000⣼7E8000⡿7F8100⠘298100⡇298000⢸7E8000⠚7E8000⣾7F8000⠘7F8100⢻7E8000⣧295500⣤2A5300⠋2A8000⣼7F8000⢠558000⣧558000⣼7F8100⢻808100⠘808100⢸298100⡇297F00⠘298000⠛297F00⠛298000⠛298000⠛297F00⠛297F00⠛297F00⠛298100⠛298100⠛298100⠛298000⠛297F00⠛297F00⠛297F00⠛297F00⠃"},
	{uniqueID = "minecraft:dye", id = "351:3", name = "Какао-бобы", price = 0.03},
	{uniqueID = "minecraft:reeds", id = "338", name = "Сахарный тростник", price = 0.03},
	{uniqueID = "minecraft:nether_wart", id = "372", name = "Адский нарост", price = 0.02},
	{uniqueID = "minecraft:ender_pearl", id = "368", name = "Жемчуг Эндера", price = 0.5},
	{uniqueID = "minecraft:bone", id = "352", name = "Кость", price = 0.2},
	{uniqueID = "minecraft:leather", id = "334", name = "Кожа", price = 0.2},
	{uniqueID = "minecraft:glowstone_dust", id = "348", name = "Светящаяся пыль", price = 0.1},
	{uniqueID = "minecraft:nether_star", id = "399", name = "Адская звезда", price = 128.9},
	{uniqueID = "minecraft:dragon_egg", id = "122", name = "Яйцо дракона", price = 194.22},
  
	--Индастриал
	{uniqueID = "IC2:itemRubber", id = "4099", name = "Резина", price = 0.0016},
	{uniqueID = "IC2:blockMachine", id = "202:11", name = "Утилизатор", price = 1.48},
	{uniqueID = "IC2:blockMachine", id = "202:5", name = "Компрессор", price = 1.18},
	{uniqueID = "IC2:blockMachine", id = "202:13", name = "Индукционная печь", price = 4.18},
	{uniqueID = "IC2:blockMachine", id = "202:2", name = "Электропечь", price = 0.98},
	{uniqueID = "IC2:blockMachine2", id = "203:3", name = "Термальная центрифуга", price = 11.32},
	{uniqueID = "IC2:blockMachine2", id = "203:5", name = "Рудопромывочный механизм", price = 3.84},
	{uniqueID = "IC2:blockMachine", id = "202:3", name = "Дробитель", price = 1.18},
	{uniqueID = "IC2:blockElectric", id = "200:2", name = "МФЭХ", price = 35.56},
	{uniqueID = "IC2:blockElectric", id = "200:1", name = "МФЭ", price = 8.48},
	{uniqueID = "IC2:blockElectric", id = "200", name = "Энергохранилище", price = 1.02},
	{uniqueID = "IC2:blockMachine2", id = "203:4", name = "Маталлоформовочный механизм", price = 2.7},
	{uniqueID = "IC2:blockMachine", id = "202:6", name = "Жидкостниый/Твердотельный наполняющий механизм", price = 1.53},
	{uniqueID = "IC2:blockMachine", id = "202:4", name = "Экстрактор", price = 1.18},
	{uniqueID = "IC2:blockMachine2", id = "203:9", name = "Консервирующий механизм", price = 1.66},
	{uniqueID = "IC2:blockKineticGenerator", id = "192", name = "Кинетический ветрогенератор", price = 2.5},
	{uniqueID = "IC2:blockGenerator", id = "194:9", name = "Кинетический генератор", price = 3.5},
	{uniqueID = "IC2:itemwcarbonrotor", id = "4296", name = "Углеволоконный ротор ветрогенератора", price = 16},
	{uniqueID = "IC2:blockGenerator", id = "194", name = "Генератор", price = 0.98},
	{uniqueID = "IC2:upgradeModule", id = "4270", name = "Улучшение \"Ускоритель\"", price = 15.94},
	{uniqueID = "IC2:upgradeModule", id = "4270:2", name = "Улучшение \"Энергохранитель\"", price = 0.77},
	{uniqueID = "IC2:itemArmorEnergypack", id = "4184", name = "Энергетический ранец", price = 12.09},
	-- {uniqueID = "", id = "4193:26", name = "Лазуротроновый кристалл", price = 3.95},
	-- {uniqueID = "", id = "4192:27", name = "Энергетический кристалл", price = 1.89},
	-- {uniqueID = "", id = "4191:26", name = "Продвинутый аккумулятор", price = 0.61},
	-- {uniqueID = "", id = "4189", name = "Незаряженный аккумулятор", price = 0.33},
	{uniqueID = "IC2:blockMachine", id = "202", name = "Основной корпус механизма", price = 0.8},
	{uniqueID = "IC2:blockMachine", id = "202:12", name = "Продвинутый корпус механизма", price = 2.5},
	-- {uniqueID = "", id = "4125", name = "Элекстросхема", price = 0.38},
	-- {uniqueID = "", id = "4126", name = "Продвинутая элекстросхема", price = 0.88},
	-- {uniqueID = "", id = "4199", name = "Изолированный медный провод", price = 0.03},
	-- {uniqueID = "IC2:upgradeModule", id = "4270:6", name = "Pulling Upgrade", price = 1.5},
	{uniqueID = "IC2:upgradeModule", id = "4270:3", name = "Улучшение \"Выталкиватель\"", price = 1.24},
	{uniqueID = "IC2:upgradeModule", id = "4270:4", name = "Улучшение \"Выталкиватель жидкостей\"", price = 1.28},
	-- {uniqueID = "", id = "4130", name = "Углепластик", price = 0.4},
	-- {uniqueID = "", id = "4127", name = "Композит", price = 0.45},
	-- {uniqueID = "", id = "4111:13", name = "Серная пыль", price = 0.2},
	-- {uniqueID = "", id = "4199:9", name = "Стекловолоконный провод", price = 0.52},
	-- {uniqueID = "", id = "4196:26", name = "Продвинутый заряжающий аккумулятор", price = 10},
	-- {uniqueID = "", id = "4198:26", name = "Заряжающий лазуротроновый кристалл", price = 53.36},
	-- {uniqueID = "", id = "4197:26", name = "Заряжающий энергетический кристалл", price = 23.88},
  
  -- лазуритовый ранец !!!!!!
	-- {uniqueID = "", id = "4152:25", name = "Электроключ", price = 2.35},
	-- {uniqueID = "", id = "4811", name = "Гравитул", price = 31.16},
	-- {uniqueID = "", id = "4812", name = "Улучшенный алмазный бур", price = 46.67},
	-- {uniqueID = "", id = "4181", name = "Электрический реактивный ранец", price = 13.16},
	-- {uniqueID = "", id = "4172", name = "Нано-шлем", price = 14.59},
	-- {uniqueID = "", id = "4806:26", name = "Улучшенный наножилет", price = 67.07},
	-- {uniqueID = "", id = "4173", name = "Нано-кираса", price = 7.33},
	-- {uniqueID = "", id = "4174", name = "Нано-поножи", price = 6.93},
	-- {uniqueID = "", id = "4175", name = "Нано-ботинки", price = 6.13},
	-- {uniqueID = "", id = "4160", name = "Нано-сабля", price = 6.43},
	{uniqueID = "IC2:blockMachine2", id = "203:2", name = "Автосадовник", price = 7.16},
	-- {uniqueID = "", id = "204:7", name = "Сборщик урожая", price = 26.46},
	-- {uniqueID = "", id = "4217:1", name = "Охлаждающий стержень 60к", price = 7.3},
	-- {uniqueID = "", id = "4200:9", name = "Капсула хладагента", price = 0.5},

	-- --Реакторы
	-- {uniqueID = "", id = "4206:1", name = "Топливный стержень (Уран)", price = 1.6},
	-- {uniqueID = "", id = "4208:1", name = "Счетверённый топливный стержень (Уран)", price = 6.9},
	-- {uniqueID = "", id = "4219", name = "Теплоёмкая реакторная пластина", price = 1.35},
	-- {uniqueID = "", id = "4221:1", name = "Теплообменник", price = 1.18},
	-- {uniqueID = "", id = "4224:1", name = "Продвинутый теплообменник", price = 3.42},
	-- {uniqueID = "", id = "4227:1", name = "Разогнанный теплоотвод", price = 2.48},
	-- {uniqueID = "", id = "4229:1", name = "Алмазный теплоотвод", price = 2.96},
	-- {uniqueID = "", id = "4223:1", name = "Компонентный теплообменник", price = 1.58},
	-- {uniqueID = "", id = "194:5", name = "Ядерный реактор", price = 36.06},
	-- {uniqueID = "", id = "195", name = "Реакторная камера", price = 10.2},
	-- {uniqueID = "", id = "198", name = "Реакторный проводник красного сигнала", price = 0.7},
	-- {uniqueID = "", id = "181", name = "Укреплённый камень", price = 0.5},
	-- {uniqueID = "", id = "183", name = "Укреплённое стекло", price = 183},

	-- --Адвансед панельки
	-- {uniqueID = "", id = "228", name = "Молекулярный преобразователь", price = 40.35},
	-- {uniqueID = "", id = "194:3", name = "Солнечная панель", price = 1.89},
	-- {uniqueID = "", id = "741", name = "Солнечная панель 2-го уровня", price = 15.52},
	-- {uniqueID = "", id = "741:1", name = "Солнечная панель 3-го уровня", price = 125.02},
	-- {uniqueID = "", id = "741:2", name = "Солнечная панель 4-го уровня", price = 1002.07},
	-- {uniqueID = "", id = "4305:9", name = "Часть саннариума", price = 1},
	-- {uniqueID = "", id = "4305", name = "Саннариум", price = 9},
	-- {uniqueID = "", id = "4305:8", name = "Излучающая армированная пластина", price = 24.8},
	-- {uniqueID = "", id = "4305:7", name = "Армированная железная пластина", price = 8},

	-- --Нуклиар контроль
	-- {uniqueID = "", id = "677:7", name = "Стационарный энергосчётчик", price = 2},
	-- {uniqueID = "", id = "677:9", name = "Продвинутая информационная панель", price = 7},
	-- {uniqueID = "", id = "4927:1", name = "Улучшение оЦветностьп", price = 1},
	-- {uniqueID = "", id = "4927", name = "Улучшение оУсиление сигранап", price = 3},
	-- {uniqueID = "", id = "4919", name = "Набор с дистанционным датчиком", price = 2},
	-- {uniqueID = "", id = "4921", name = "Набор для счётчика энергии", price = 0.8},
	-- {uniqueID = "", id = "677", name = "Датчик температуры", price = 1.7},

	-- --Драконик эволюшн
	-- {uniqueID = "", id = "1701", name = "Наполнитель энергии", price = 58},
	-- {uniqueID = "", id = "1695", name = "Дракониевый блок", price = 23.94},
	-- {uniqueID = "", id = "1707", name = "Заряженный драконием обсидиан", price = 26},

	-- --Термал экспеншн
	-- {uniqueID = "", id = "656", name = "Силовой конвертер", price = 12.3},
	-- {uniqueID = "", id = "667", name = "Рамка механизма (Основная)", price = 0.9},
	-- {uniqueID = "", id = "667:1", name = "Рамка механизма (Усиленная)", price = 1.8},
	-- {uniqueID = "", id = "667:2", name = "Рамка механизма (Укреплённая)", price = 2.62},
	-- {uniqueID = "", id = "667:3", name = "Рамка механизма (Резонирующая)", price = 6.72},
	-- {uniqueID = "", id = "657:8", name = "Резонируюций водяной накопитель", price = 9},
	-- {uniqueID = "", id = "657:11", name = "Резонирующий фитогенный светильник", price = 9},
	-- {uniqueID = "", id = "657:7", name = "Резонирующий вулканический пресс", price = 9},
	-- {uniqueID = "", id = "657:5", name = "Резонирующий распределитель жидкостей", price = 9},
	-- {uniqueID = "", id = "657:3", name = "Резонирующая индукционная плавильня", price = 657:3},
	-- {uniqueID = "", id = "657:2", name = "Резонирующая лесопилка", price = 9},
	-- {uniqueID = "", id = "657:1", name = "Резонирующий измельчитель", price = 9},
	-- {uniqueID = "", id = "657:4", name = "Резонирующий магмовый тигель", price = 9},
	-- {uniqueID = "", id = "6077:4", name = "Резонируюций фильтр", price = 0.9},
	-- {uniqueID = "", id = "6077", name = "Фильтр", price = 0.2},
	-- {uniqueID = "", id = "6078:4", name = "Резонируюций поисковик", price = 0.9},
	-- {uniqueID = "", id = "6075:4", name = "Резонирующий сервомеханизм", price = 0.9},
	-- {uniqueID = "", id = "4802:128", name = "Расширение: Вторичная принимающая катушка", price = 0.7},
	-- {uniqueID = "", id = "4802:129", name = "Расширение: Разогнанный модульный редуктор", price = 1.1},
	-- {uniqueID = "", id = "4802:130", name = "Расширение: Пространственно-временной унификатор флакса", price = 2},
	-- {uniqueID = "", id = "4673:76", name = "Слиток эндериума", price = 0.9},
	-- {uniqueID = "", id = "4673:74", name = "Синаловый слиток", price = 0.13},
	-- {uniqueID = "", id = "4673:72", name = "Инваровый слиток", price = 0.1},
	-- {uniqueID = "", id = "4673:75", name = "Ламиумовый слиток", price = 0.2},
	-- {uniqueID = "", id = "4673:71", name = "Электрумовый слиток", price = 0.1},
	-- {uniqueID = "", id = "4673:513", name = "Пыль криотеума", price = 0.2},
	-- {uniqueID = "", id = "4673:512", name = "Пыль пиротеума", price = 0.2},
	-- {uniqueID = "", id = "4802:312", name = "Расширение: Ускоренная экструзия", price = 0.9},
	-- {uniqueID = "", id = "4802:313", name = "Расширение: Вулканический катализатор", price = 0.9},
	-- {uniqueID = "", id = "4802:314", name = "Расширение: Пирокластическое генерирование", price = 0.9},
	-- {uniqueID = "", id = "4673:68", name = "Никелевый слиток", price = 0.1},
	-- {uniqueID = "", id = "4673:69", name = "Платиновый слиток", price = 1},
	-- {uniqueID = "", id = "6336", name = "Флаксовый слиток", price = 0.9},
	-- {uniqueID = "", id = "4798:5", name = "Резонирующий флаксовый конденсатор", price = 4},
	-- {uniqueID = "", id = "4673:1028", name = "Basalz Rod", price = 0.4},
	-- {uniqueID = "", id = "4673:1024", name = "Бурановый стержень", price = 0.5},
	-- {uniqueID = "", id = "4672:2", name = "Ведро резонирующего эндериума", price = 2.3},
	-- {uniqueID = "", id = "4672", name = "Ведро дестабилизированного красного камня", price = 0.9},
	-- {uniqueID = "", id = "4672:4", name = "Ведро ледяного кристеума", price = 2},
	-- {uniqueID = "", id = "4672:1", name = "Ведро заряженного светящегося камня", price = 0.9},
	-- {uniqueID = "", id = "4672:8", name = "Ведро тектонического петротеума", price = 1.5},
	-- {uniqueID = "", id = "4672:3", name = "Ведро пылающего пиротеума", price = 1.2},

	-- --Майнфактори
	-- {uniqueID = "", id = "833", name = "Сеятель", price = 2.5},
	-- {uniqueID = "", id = "833:1", name = "Рыболов", price = 2.8},
	-- {uniqueID = "", id = "833:2", name = "Комбайн", price = 3},
	-- {uniqueID = "", id = "833:3", name = "Фермер", price = 2.6},
	-- {uniqueID = "", id = "833:4", name = "Удобритель", price = 2.6},
	-- {uniqueID = "", id = "833:12", name = "Селекционер", price = 3.2},
	-- {uniqueID = "", id = "833:13", name = "Молотилка", price = 2.7},
	-- {uniqueID = "", id = "833:15", name = "Сепаратор", price = 4},
	-- {uniqueID = "", id = "836:13", name = "Бойня", price = 2.6},
	-- {uniqueID = "", id = "864:6", name = "Сборщик фруктов", price = 2.8},
	-- {uniqueID = "", id = "5574:3", name = "Улучшение (Медь)", price = 0.5},

	-- --Дварвен сити
	-- {uniqueID = "", id = "6382", name = "Вис Материя", price = 3.85},
	-- {uniqueID = "", id = "6338", name = "Тёмная Материя", price = 2.7},
	-- {uniqueID = "", id = "6388", name = "Солнечная Материя", price = 3.11},
	-- {uniqueID = "", id = "6380", name = "Живая Материя", price = 2.6},
	-- {uniqueID = "", id = "6406", name = "Ледяная Материя", price = 2.6},
	-- {uniqueID = "", id = "6397", name = "Трижды сжатый камень", price = 10},
	-- {uniqueID = "", id = "6355", name = "Дважды сжатый адский кирпич", price = 15},
	-- {uniqueID = "", id = "6776", name = "Печать алхимии", price = 10},
	-- {uniqueID = "", id = "6687", name = "Печать ДНК", price = 125},
	-- {uniqueID = "", id = "6791", name = "Печать смерти", price = 62.7},
	-- {uniqueID = "", id = "6817", name = "Кубическая печать", price = 70},
	-- {uniqueID = "", id = "6738", name = "Печать обороны", price = 20},
	-- {uniqueID = "", id = "6777", name = "Механическая печать", price = 28.04},
	-- {uniqueID = "", id = "6698", name = "Печать света", price = 20},
	-- {uniqueID = "", id = "6787", name = "Флаксовая печать", price = 60},
	-- {uniqueID = "", id = "6820", name = "Печать жизни", price = 2.6},
	-- {uniqueID = "", id = "6825", name = "Модульная печать", price = 16},
	-- {uniqueID = "", id = "6785", name = "Жидкостная печать", price = 20},
	-- {uniqueID = "", id = "6748", name = "Печать защиты", price = 35},
	-- {uniqueID = "", id = "6710", name = "Печать удачи", price = 15},
	-- {uniqueID = "", id = "6815", name = "Печать безопасности", price = 40},
	-- {uniqueID = "", id = "6737", name = "Лазерная печать", price = 30},
}

local depositConfig = {
  ["minecraft:iron_ingot"] = {name = "Железный слиток", id = 265, amount = 1, price = 0.1},
  ["minecraft:iron_block"] = {name = "Железный блок", id = 42, amount = 1, price = 0.9},
}

for k, v in ipairs(itemConfig) do
  v.quantity = v.quantity or 1
  v.amount = 0
  local _, dmg = string.match(v.id, "(%d+):(%d+)")
  v.dmg = tonumber(dmg) or 0
end
for k, v in pairs(depositConfig) do
  v.uniqueID = k
end

-----------------------------------------------------------

local function compare(a,b)
  return a.name < b.name
end
  
table.sort(itemConfig, compare)


local function getNewText(dist1, dist2, dist3, text1, text2, text3)
  local column3 = text3 .. string.rep(" ", dist3 - unicode.wlen(text3))
  local column2 = text2 .. string.rep(" ", dist2 - unicode.wlen(text2))
  local column1 = text1 .. string.rep(" ", dist1 - unicode.wlen(text1))

  return column1 .. column2 .. column3
end

local function getButtonText(text)
  local buttonWidth = 16
  local textWidth = unicode.wlen(text)

  if textWidth < buttonWidth then
    local margin = math.ceil((buttonWidth - textWidth) / 2)
    text = string.rep(" ", buttonWidth - textWidth - margin) .. text .. string.rep(" ", margin)
  end

  return text
end

local function sS(text, width) -- stringSpacing
  width = width or 38
  local wlen = unicode.wlen(text) or 0
  local margin = math.floor((width - wlen) / 2)

  return string.rep(" ", margin) .. text .. string.rep(" ", width - wlen - margin)
end





function getDepositList()
  depositListStrings = {}
  depositListData = {}

  local counter = 1
  for uniqueID, data in pairs(depositConfig) do
    table.insert(depositListData, data)

    local row = getNewText(29, 10, 10, counter .. ". " .. data.name, data.amount .. "шт.", data.price .. "$ ")
    
    table.insert(depositListStrings, row)
    counter = counter + 1
  end

  return depositListStrings
end





function getItemData(uniqueID, label, dmg)
  return ae2.getItemsInNetwork({name = uniqueID, label = label or nil, damage = dmg or nil})[1]
end

function getItemAmount(uniqueID, label, dmg)
  local itemData = getItemData(uniqueID, label, dmg)
  if itemData then
    return itemData.size
  end

  return 0
end

function updateItemsAmount()
  for _, data in pairs(itemConfig) do
    data.amount = getItemAmount(data.uniqueID, data.label, data.dmg)
  end

  return true
end

function getListRow(counter, name, id, amount, price)
  local tempid = " (#" .. id .. ")"
  local tempname = " " .. counter .. ". " .. name
  local newname = unicode.wlen(tempname) > (60 - unicode.wlen(tempid)) and (unicode.sub(tempname, 1, 57 - unicode.wlen(tempid)) .. "...") or tempname
  local row = getNewText(60, 15, 15, newname .. tempid, amount .. " шт.", price .. "$" )

  return row
end

function getItemList(subtext)
  updateItemsAmount()

  itemListStrings = {}
  itemListData = {}

  local counter = 1

  if subtext and subtext ~= "" then
    for _, data in ipairs(itemConfig) do
      local lowtext = string.lower(subtext)
      if string.find(string.lower(data.uniqueID), lowtext) 
        or (data.label and string.find(string.lower(data.label), lowtext)) 
        or string.find(string.lower(data.id), lowtext) 
        or string.find(unicode.lower(data.name), unicode.lower(subtext))
      then
        table.insert(itemListData, data)

        getListRow(counter, data.name, data.id, data.amount, data.price)

        table.insert(itemListStrings, row)
        counter = counter + 1
      end
    end
  else
    for _, data in ipairs(itemConfig) do
      table.insert(itemListData, data)

      local tempid = " (#" .. data.id .. ")"
      local tempname = " " .. counter .. ". " .. data.name
      local newname = unicode.wlen(tempname) > (60 - unicode.wlen(tempid)) and (unicode.sub(tempname, 1, 57 - unicode.wlen(tempid)) .. "...") or tempname
      local row = getNewText(60, 15, 15, newname .. tempid, data.amount .. " шт.", data.price .. "$" )

      table.insert(itemListStrings, row)
      counter = counter + 1
    end
  end

  return itemListStrings
end








function setPageVisible(page, bVisible)
  for _, name in pairs(pages[page]) do
    gui.setVisible(myGui, name, bVisible)
    if bVisible then gui.setEnable(myGui, name, true, true) end
  end
end

function setBackButtonEnable(bEnable)
  local buttons = {backbutton_up, backbutton, backbutton_down}

  for key, value in ipairs(buttons) do
    gui.setVisible(myGui, value, bEnable)
    if bEnable then gui.setEnable(myGui, value, true, true) end
  end
end

function drawPage(page)
  setPageVisible(curPage, false)
  setPageVisible(page, true)

  if page == 2 or page == 3 then
    setBackButtonEnable(true)
  else
    setBackButtonEnable(false)
  end

  curPage = page
end


function exitButtonCallback(guiID, id)
  local result = gui.getYesNo(sS(""), sS("Выход только для разработчика!"), sS(""))
  if result == true and pimPlayer and pimPlayer == "LIMI_np" then
    gui.exit()
  end
  gui.displayGui(myGui)
end

function updateList(guiID, listID, subtext)
  gui.clearList(guiID, list_1_ID)

  for _, value in ipairs(getItemList(subtext)) do
    gui.insertList(guiID, list_1_ID, value)
  end
end

function updateBuyList()
  updateItemsAmount()
  updateList(myGui, list_1_ID, myGui[filterentry].text)
end

function loadScreen(func, newPage)
  newPage = newPage or curPage

  if func then func() end
  drawPage(newPage)
end

function backButtonCallback() drawPage(1) end
function drawBuyPage() 
  drawPage(2) 
  buyListCallback(myGui, list_1_ID, 1)
end
function drawDepositPage() drawPage(3) end




function depositListCallback(guiID, id, rowID, text)
  depositListChoose = rowID

  gui.setText(guiID, depositEntry2, tonumber(guiID[depositEntry1].text) * depositListData[depositListChoose].price)
end

function calculateDepositEntry1(guiID, id, text)
  if tonumber(text) == nil then
    text = string.match(text , "%d+") or 1
    gui.setText(guiID, id, text)
  end

  local result = tonumber(text) / depositListData[depositListChoose].price
  gui.setText(guiID, depositEntry1, result)
end

function calculateDepositEntry2(guiID, id, text)
  if tonumber(text) == nil then
    text = string.match(text , "%d+") or 1
    gui.setText(guiID, id, text)
  end

  local result = tonumber(text) * depositListData[depositListChoose].price
  gui.setText(guiID, depositEntry2, result)
end

function itemsCountByID(uniqueID)
  if pim.getInventoryName() ~= pimPlayer then showMsg("Возникла ошибка при считывании инвентаря") return 0 end

  local count = 0

  for i = 1, 40 do
    if pim.getStackInSlot(i) then
      if pim.getStackInSlot(i).id == uniqueID then
        count = count + pim.getStackInSlot(i).qty
      end
    end
  end

  return count
end

function takeawayItemsCountByID(uniqueID, amount)
  if pim.getInventoryName() ~= pimPlayer then return false end

  for i = 1, 40 do
    if pim.getStackInSlot(i) then
      if pim.getStackInSlot(i).id == uniqueID then
        local count = pim.getStackInSlot(i).qty
        if count >= amount then
          pim.pushItemIntoSlot(CHEST_PUSH_SIDE, i, amount)
          return true
        else
          pim.pushItemIntoSlot(CHEST_PUSH_SIDE, i)
          amount = amount - count
        end
      end
    end
  end

  return false
end

function showMsg(msg1, msg2, msg3)
  gui.showMsg(msg1 or sS(""), msg2 or sS(""), msg3 or sS(""))
end

function updatePlayerMoney()
  if not pimPlayer then return end

  local money = getPlayerMoney(pimPlayer)
  gui.setText(myGui, welcomeLabel, "Добро пожаловать " .. pimPlayer .. ", в наличии - " .. money .. " защекоинов.")
end

function depositSuccessCallback(guiID, id)
  if not pimPlayer then return showMsg("Вы должны стоять на плите") end

  local uniqueID = depositListData[depositListChoose].uniqueID
  local amount = tonumber(guiID[depositEntry1].text)

  if not uniqueID then return showMsg("Ошибка в названии предмета") end
  local currentCount = itemsCountByID(uniqueID)

  if currentCount < amount then return showMsg("У вас недостаточно средств") end

  local bSuccess = takeawayItemsCountByID(uniqueID, amount)
  if not bSuccess then showMsg("Возникла ошибка при пополнении!") end

  local result = amount * depositListData[depositListChoose].price
  
  setPlayerMoney(pimPlayer, result)
  addLog(string.format("%s пополнил счет на %s защекоинов, внесены предметы - %s, (x%s), цена за 1шт. - %s$", pimPlayer, result, uniqueID, amount, depositListData[depositListChoose].price))
  showMsg("Пополнение произошло успешно", "На ваш счет начислено " .. result .. "$", "Изъяты предметы - " .. depositListData[depositListChoose].name .. "(x" .. amount .. ")")
  updatePlayerMoney()
end

function buyListCallback(guiID, id, rowID, text)
  buyListChoose = rowID

  local result = tonumber(guiID[buyEntry1].text) * itemListData[buyListChoose].price
  gui.setText(guiID, buyInfo, "К оплате - " .. result .. "$             ")

  if itemListData[buyListChoose].image then
    local picture = imagefromString(itemListData[buyListChoose].image)

    print(picture[1], picture[2])
    print()
    print(serialization.serialize(picture))
  end
end

function calculateBuyEntry(guiID, id, text)
  if tonumber(text) == nil then
    text = string.match(text , "%d+") or 1
    gui.setText(guiID, id, text)
  end

  local result = tonumber(text) * itemListData[buyListChoose].price
  gui.setText(guiID, buyInfo, "К оплате - " .. result .. "$             ")
end

function getEmptySlots()
  if not pimPlayer then return 0 end
  if pimPlayer ~= pim.getInventoryName() then return 0 end

  local counter = 0
  for i = 1, 40 do
    if not pim.getStackInSlot(i) then
      counter = counter + 1
    end
  end

  return counter
end

function buySuccessCallback(guiID, id)
  if not pimPlayer then return showMsg("Встаньте на плиту") end
  if not itemListData[buyListChoose] then return showMsg("Возникла ошибка при инициализации товара!") end

  local uniqueID = itemListData[buyListChoose].uniqueID
  local amount = tonumber(guiID[buyEntry1].text)
  if not amount then return showMsg("Возникла ошибка при buyEntry1!") end

  local itemData = getItemData(uniqueID, itemListData[buyListChoose].label, itemListData[buyListChoose].dmg)
  if not itemData or itemData.name ~= uniqueID then return showMsg("Invalid item, сообщите LIMI_np") end

  -- Проверка надурака
  local row1 = "Вы хотите купить за " .. itemListData[buyListChoose].price .. "$ (" .. amount .. " шт.)"
  local row2 = unicode.wlen(itemListData[buyListChoose].name) > 38 and (unicode.sub(itemListData[buyListChoose].name, 1, 36) .. "-") or (itemListData[buyListChoose].name .. "?")
  local row3 = unicode.wlen(itemListData[buyListChoose].name) > 38 and (unicode.sub(itemListData[buyListChoose].name, 37) .. "?") or nil
  local result = gui.getYesNo(row1, row2, row3)
  if not result then
    return gui.displayGui(myGui)
  end

  -- 
  if itemData.size < amount then return showMsg("Недостаточно предметов в магазине") end
  local price = itemListData[buyListChoose].price * amount

  if getPlayerMoney(pimPlayer) < price then return showMsg("У вас недостаточно средств, пополнитее счет") end

  -- Проверка поместиться ли лут в инвентарь
  local maxSize = itemData.maxSize
  if not maxSize then return showMsg("Ошибка просчета стака предмета") end

  local emptySlots = math.ceil(amount / maxSize)

  if emptySlots > getEmptySlots() then return showMsg("У вас недостаточно места в инвентаре") end
  if not itemListData[buyListChoose].dmg then return showMsg("У предмета отсутствует DMG") end

  local fp = {id = uniqueID, dmg = itemListData[buyListChoose].dmg} 

  setPlayerMoney(pimPlayer, -price)

  local _amount = amount
  if _amount > 64 then
    while _amount > 0 do
      local exportResult = mei.exportItem(fp, "UP", _amount)
      addLog(string.format("%s'у выдано %s [dmg:%s] в количестве %s шт.", pimPlayer, exportResult.id, exportResult.dmg, exportResult.size))
      _amount = _amount - 64
    end
  else
    local exportResult = mei.exportItem(fp, "UP", _amount)
    addLog(string.format("%s'у выдано %s [dmg:%s] в количестве %s шт.", pimPlayer, exportResult.id, exportResult.dmg, exportResult.size))
  end
  
  addLog(string.format("%s купил %s (x%s) за %s$", pimPlayer, itemListData[buyListChoose].name, amount, price))
  local peace1 = "Получены предметы "
  local peace3 = "(x" .. amount .. ")"
  local pwlen = unicode.wlen(peace1) + unicode.wlen(peace3)
  local peace2 = unicode.wlen(itemListData[buyListChoose].name) > (38 - pwlen) and (unicode.sub(itemListData[buyListChoose].name, 1, 35 - pwlen) .. "...") or itemListData[buyListChoose].name
  showMsg("Покупка произошла успешно", peace1 .. peace2 .. peace3, "Со счета снято " .. price .. " защекоинов")
  updatePlayerMoney()
  
  itemListData[buyListChoose].amount = getItemAmount(itemListData[buyListChoose].uniqueID, itemListData[buyListChoose].label, itemListData[buyListChoose].dmg)
  gui.renameList(myGui, list_1_ID, buyListChoose, getListRow(buyListChoose, itemListData[buyListChoose].name, itemListData[buyListChoose].id, itemListData[buyListChoose].amount, itemListData[buyListChoose].price))
end



myGui = gui.newGui(2, 2, 158, 48, true)                                                                       -- Главная менюшка
welcomeLabel = gui.newLabel(myGui, 2, 1, "") -- Строка приветствия


backbutton_up = gui.newButton(myGui, 138, 1, getButtonText(""), backButtonCallback)                               -- Вернуться на главную страницу
backbutton = gui.newButton(myGui, 138, 2, getButtonText("В главное меню"), backButtonCallback)                               -- Вернуться на главную страницу
backbutton_down = gui.newButton(myGui, 138, 3, getButtonText(""), backButtonCallback)                               -- Вернуться на главную страницу
setBackButtonEnable(false)

-- firstPage
buymenu_up = gui.newButton(myGui, "center", 17, getButtonText(""), drawBuyPage)
buymenu = gui.newButton(myGui, "center", 18, getButtonText("Покупка"), drawBuyPage)
buymenu_down = gui.newButton(myGui, "center", 19, getButtonText(""), drawBuyPage)

depositmenu_up = gui.newButton(myGui, "center", 21, getButtonText(""), drawDepositPage)
depositmenu = gui.newButton(myGui, "center", 22, getButtonText("Пополнение"), drawDepositPage)
depositmenu_down = gui.newButton(myGui, "center", 23, getButtonText(""), drawDepositPage)

exitbutton_up = gui.newButton(myGui, "center", 25, getButtonText(""), exitButtonCallback) -- @todo Убрать когда сделаю шоп
exitbutton = gui.newButton(myGui, "center", 26, getButtonText("Выход"), exitButtonCallback) -- @todo Убрать когда сделаю шоп
exitbutton_down = gui.newButton(myGui, "center", 27, getButtonText(""), exitButtonCallback) -- @todo Убрать когда сделаю шоп

pages[1] = {buymenu_up, buymenu, buymenu_down, 
            depositmenu_up, depositmenu, depositmenu_down, 
            exitbutton_up, exitbutton, exitbutton_down}

-- buyPage 
filter = gui.newLabel(myGui, 2, 3, "Фильтр:")
filterentry = gui.newText(myGui, 9, 3, 30, "", updateList)
list_1_ID = gui.newList(myGui, 2, 5, 94, 42, getItemList(), buyListCallback, "                         Название                         |  В наличии   |   Цена за 1шт.  ")
buyLabel = gui.newLabel(myGui, 98, 6, "Количество предметов:")
buyEntry1 = gui.newText(myGui, 98, 8, 10, "1", calculateBuyEntry)
buyInfo = gui.newLabel(myGui, 98, 10, "К оплате - " .. itemListData[1].price .. "$")

buySuccess_up = gui.newButton(myGui, 98, 12, getButtonText(""), buySuccessCallback)
buySuccess = gui.newButton(myGui, 98, 13, getButtonText("Купить"), buySuccessCallback)
buySuccess_down = gui.newButton(myGui, 98, 14, getButtonText(""), buySuccessCallback)

pages[2] = {filter, filterentry, list_1_ID, buyLabel, buyEntry1, buyInfo, buySuccess_up, buySuccess, buySuccess_down} setPageVisible(2, false)

-- depositPage
depositList = gui.newList(myGui, 10, 10, 50, 10, getDepositList(), depositListCallback, "A List")
depositLabel = gui.newLabel(myGui, 62, 10, "Количество предметов:")
depositEntry1 = gui.newText(myGui, 62, 12, 10, "1", calculateDepositEntry2)
depositInfo = gui.newLabel(myGui, 62, 14, "Вам будет начислено:")
depositEntry2 = gui.newText(myGui, 62, 16, 10, "0.1", calculateDepositEntry1)
depositSuccess = gui.newButton(myGui, 62, 18, "Пополнить", depositSuccessCallback)
pages[3] = {depositList, depositLabel, depositEntry1, depositInfo, depositEntry2, depositSuccess} setPageVisible(3, false)

-- loadingPage
loadingLabel = gui.newLabel(myGui, "center", 22, "Подождите, загрузка данных...")
pages[4] = {loadingLabel} setPageVisible(4, false)

-- startMenu
startLabel = gui.newLabel(myGui, "center", 21, "Добро пожаловать в наш магазин.")
startLabel2 = gui.newLabel(myGui, "center", 22, "Чтобы продолжить, авторизируйтесь встав на плиту")
pages[5] = {startLabel,startLabel2 } setPageVisible(5, false)




-- Programm

gui.clearScreen()
gui.setTop(prgName)

drawPage(5)

function checkPimPlayer()
  if gui.pimPlayer ~= pimPlayer then
    if gui.pimPlayer then
      pimPlayer = gui.pimPlayer
      -- addLog(string.format("%s встал на плиту", pimPlayer))

      drawPage(4)
  
      loadScreen(updateBuyList(), 1)
      local money = getPlayerMoney(pimPlayer)
      gui.setText(myGui, welcomeLabel, "Добро пожаловать " .. pimPlayer .. ", в наличии - " .. money .. " защекоинов.")

      buyListCallback(myGui, list_1_ID, 1)
    else
      -- addLog(string.format("%s покинул плиту", pimPlayer))
      pimPlayer = nil
      drawPage(5)
      gui.setText(myGui, welcomeLabel, "                                                                              ")
    end
  end
end

while true do
  gui.runGui(myGui)
  checkPimPlayer()
end
